include ../base

import strformat, sugar
from algorithm import sort
from os import existsFile, moveFile, tryRemoveFile
from parseutils import parseSaturatedNatural, skipUntil
from sequtils import keepIf, map, mapIt, toSeq
from times import getDateStr

import tempfile

type
  Header = tuple[kind: string, scope: string, desc: string]
  Commit = object
    hash: string
    header: Header
    body: string
    closures: seq[int]
    breaking: string

const
  itemSeparator = "#&<2#@~#2>&#"
  commitSeparator = "#++-~-~2~-~-++#"
  commitFormatParts = ["%H", "%s", "%b"]
  commitFormat = commitFormatParts.join(itemSeparator)
  cmdFetchTags = "git fetch --tags"
  cmdGetAllTags = strip(&"""git for-each-ref --format="%(refname:short){itemSeparator}%(creatordate:short)" refs/tags/*""")
  cmdGetLastTag = "git describe --tags --abbrev=0"
  cmdGetCommits = &"""git log -E --format="{commitFormat}{commitSeparator}" """
  commitKinds = {
    "": (print: false, heading: ""),
    "ci": (print: false, heading: ""),
    "chore": (print: false, heading: ""),
    "docs": (print: false, heading: ""),
    "feat": (print: true, heading: "FEATURES"),
    "fix": (print: true, heading: "BUG FIXES"),
    "perf": (print: true, heading: "PERFORMANCE"),
    "refactor": (print: false, heading: ""),
    "style": (print: false, heading: ""),
    "test": (print: false, heading: ""),

    # internal only types for printing commit metadata
    "breaking": (print: true, heading: "BREAKING CHANGES")
  }.toTable
  breakingSectionStart = "BREAKING CHANGE: "
  closesSectionStart = "Closes #"
  commitKindWidest = map(toSeq(keys(commitKinds)), (k) => k.len).max
  usageMessage = """
  Usage: fugitive changelog [file] [--tag|-t:<tag>] [--overwrite|-o]
    [--no-anchor] [--init]

  Write the list of all changes since the last git tag. Commits
  should be formatted according to the Conventional Commits
  specification. This is used to categorize and filter commits, ie.
  internally focused changes will not be listed.

  To create a new changelog from scratch, pass the `init` flag to
  write all past tagged releases and their commits.

  If `file` is not provided, changes will be written to `stdout`.

  When the `overwrite` flag is absent, changes will be prepended
  to `file` if it exists. Has no effect when writing to `stdout`
  or when using `--init` to create a new changelog.

  HTML anchor elements are added for linking purposes but can be
  disabled by providing the `--no-anchor` flag.

  For more information about the Conventional Commits spec, see:
  https://conventionalcommits.org/

  Example:

    fugitive changelog changelog.md --init        # start new changelog
    fugitive changelog changelog.md --tag:v1.1.0  # update changelog
  """

# parses a string of the form "{kind}{scope?}: {desc}"
proc parseHeader (header: string): Header =
  let openParen = header.find('(')

  # because the opening paren immediately follows the
  # commit type, it can't possibly be further in the string
  # than the length of the longest possible commit type + 1
  if openParen in 0..commitKindWidest + 1:
    let closeParen = header.find(')', openParen + 1)
    result = (
      kind: header[0..<openParen].strip,
      scope: header[openParen + 1..<closeParen].strip,
      desc: header[closeParen + 2..^1].strip
    )
  else:
    let colon = header.find(':')

    if colon notin 0..commitKindWidest + 1:
      # colon expected directly after commit type but not found
      # the empty kind will prevent this commit from printing
      return ("", "", "")

    result = (
      kind: header[0..<colon].strip,
      scope: "",
      desc: header[colon + 1..^1].strip
    )

# parses a string of the form "Closes #1, #2, #3" into a list of issue numbers
proc parseIssueList (closures: string): seq[int] =
  result = @[]
  var i = 0
  while i < closures.len:
    inc(i, closures.skipUntil('#', i) + 1)
    var issue = 0
    inc(i, closures.parseSaturatedNatural(issue, i))
    if issue != 0: result.add issue

proc parseBody (body: string): tuple[body: string, closures: seq[int], breaking: string] =
  let breaks = body.find(breakingSectionStart)
  let closes = body.find(closesSectionStart)
  result.body = body

  if breaks > -1:
    result.body = body[0..<breaks]

    let finish = if closes > -1: closes - 1 else: body.high
    result.breaking = wordWrap(
      body[breaks + breakingSectionStart.len..finish],
      splitLongWords = false
    )
  else:
    result.breaking = ""

  if closes > -1:
    result.closures = body[closes..body.high].parseIssueList
  else:
    result.closures = @[]

proc parseCommitList (commitList: string): seq[Commit] =
  result = @[]
  for commitRaw in commitList.split commitSeparator:
    if commitRaw.strip == "": continue

    var commit = Commit()
    let parts = commitRaw.split(itemSeparator, 3)
    commit.hash = parts[0].strip
    commit.header = parts[1].parseHeader
    (commit.body, commit.closures, commit.breaking) = parts[2].parseBody

    result.add commit
    if commit.breaking != "":
      commit.header.kind = "breaking"
      result.add commit

proc shouldPrint (commit: Commit): bool =
  commit.header.kind in commitKinds and commitKinds[commit.header.kind].print

proc sortCommits (x, y: Commit): int =
  cmp(x.header.kind, y.header.kind)

proc sortTags (x, y: tuple[tag, date: string]): int =
  cmp(x.date, y.date)

proc cleanCommitList (commitList: var seq[Commit], lastTag: string): bool =
  if commitList.len < 1: return false

  commitList.sort(sortCommits)
  commitList.keepIf(shouldPrint)
  result = true

proc output (dest: File, str: string) =
  dest.write(str)

proc getDestFile (args: Arguments): File =
  if args.len > 0 and args[0].len > 0:
    if not args[0].existsFile: return stdin
    try:
      return args[0].open(fmRead)
    except IOError:
      return stdin

proc selectFile (args: Arguments, opts: Options): tuple[fd: File, name: string, overwrite: bool] =
  if args.len > 0 and args[0].len > 0:
    if "init" notin opts and ("overwrite" in opts or "o" in opts):
      result = (args[0].open(fmWrite), args[0], true)
    else:
      let (fd, name) = mkstemp(mode = fmWrite)
      result = (fd, name, false)
  else:
    result = (stdout, "", false)

proc getLastTag (): tuple[lastTag, rev: string] =
  let (lastTagRaw, code) = execCmdEx cmdGetLastTag
  let lastTag = lastTagRaw.strip
  result = if code != 0: (lastTag, "") else: (lastTag, lastTag & "..HEAD")

proc getNewTag (opts: Options): string =
  if "tag" in opts: opts["tag"].strip
  elif "t" in opts: opts["t"].strip
  else: ""

proc getTitle (newTag, lastTag, repoUrl: string, date = getDateStr()): string =
  result = "### "
  if newTag != "":
    result &= &"[`{newTag}`]({repoUrl}/compare/{lastTag.strip}...{newTag}) ("

  result &= date
  if newTag != "": result &= ")"
  result &= "\n\n"

proc renderClosures (closures: seq[int], repoUrl: string): string =
  if closures.len == 0: return ""

  result = ", closes " & closures
    .mapIt(&"[#{it}]({repoUrl}/issues/{it})")
    .join(", ")

proc renderDescription (desc, repoUrl: string): string =
  let openParen = desc.rfind("(#")
  if openParen == -1: return desc
  let closeParen = desc.find(')', openParen + 2)

  result = desc[0..<openParen]
  var pr: int
  let skips = desc.parseSaturatedNatural(pr, start = openParen + 2)
  result &= &"([#{pr}]({repoUrl}/pull/{pr}))" & desc[openParen + 2 + skips..^1]
  if closeParen == -1: result &= ')'

proc render (commit: Commit, repoUrl: string): string =
  result = "* "
  if commit.header.scope != "":
    result &= "**" & commit.header.scope & ":** "

  if commit.header.kind == "breaking":
    result &= commit.breaking
    return

  result &= commit.header.desc.renderDescription(repoUrl)

  let shortHash = commit.hash[0..6]
  let closures = commit.closures.renderClosures(repoUrl)

  result &= &" ([`{shortHash}`]({repoUrl}/commit/{commit.hash})){closures}"

proc getCommitList (lastTag, rev: string, failFast = false, verbose = true): seq[Commit] =
  let (commits, code) = execCmdEx cmdGetCommits & rev

  if code != 0:
    if verbose:
      if rev == "":
        print "No commits found"
      else:
        print "No changes since " & lastTag

    if failFast: quit 0 else: return

  result = commits.parseCommitList
  if not result.cleanCommitList(lastTag) and verbose:
    print "No changes since " & lastTag
    if failFast: quit 0

proc parseTagList (tagInfo: string): tuple[tag, date: string] =
  let tagInfoList = tagInfo.split(itemSeparator)
  result = (tagInfoList[0], tagInfoList[1])

proc getTagList (): seq[tuple[tag, date: string]] =
  let (tags, code) = execCmdEx cmdGetAllTags

  if code != 0:
    fail tags
    quit 0

  result = tags.strip.splitLines.map(parseTagList)
  result.sort(sortTags)

proc updateChangelog (
  args: Arguments,
  opts: Options,
  commitList: seq[Commit],
  lastTag: string,
  nextTag = "",
  date = getDateStr()
) =
  let
    newTag = if nextTag != "": nextTag else: opts.getNewTag
    repoUrl = getRepoUrl()
    title = getTitle(newTag, lastTag, repoUrl, date)
    (file, path, overwrite) = selectFile(args, opts)

  if "no-anchor" notin opts:
    let anchor = if newTag != "": newTag else: date
    file.output &"<a name=\"{anchor}\"></a>\n"

  file.output title

  var headings: seq[string] = @[]
  for commit in commitList:
    if commit.header.kind notin headings:
      headings.add commit.header.kind
      file.output &"\n###### {commitKinds[commit.header.kind].heading}\n\n"

    file.output commit.render(repoUrl) & "\n"

  file.output "\n---\n\n"

  if path != "":
    # non-stdout handling
    if not overwrite:
      let origFile = args.getDestFile

      if origFile != stdin:
        for line in origFile.lines:
          file.output line & "\n"
        close origFile

      close file
      discard tryRemoveFile(args[0])
      moveFile(path, args[0])
    else:
      close file
  else:
    close file

proc initChangelog (args: Arguments, opts: Options) =
  let tagList = getTagList()

  if tagList.len == 0:
    print "There are no tagged releases, skipping changelog creation"
    quit 0

  for i, tagInfo in tagList:
    let
      (tag, date) = tagInfo
      finish = if i == tagList.high: "HEAD" else: tagList[i + 1].tag
      rev = &"{tag}..{finish}"
      commitList = getCommitList(tag, rev, verbose = false)
      nextTag = if finish == "HEAD": "" else: finish

    if finish == "HEAD" and commitList.len == 0:
      # no changes between local & remote yet
      continue

    updateChangelog(args, opts, commitList, tag, nextTag, date)

  print &"Changelog created ({tagList.len - 1} releases)"

proc changelog* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo(): fail errNotRepo

  if (execCmdEx cmdFetchTags).exitCode != 0:
    fail "Failed to update tags from remote"

  if getOptionValue(opts, "i", "init", bool):
    initChangelog(args, opts)
    quit 0

  let (lastTag, rev) = getLastTag()
  let commitList = getCommitList(lastTag, rev)
  updateChangelog(args, opts, commitList, lastTag)
  print "Changelog updated"
