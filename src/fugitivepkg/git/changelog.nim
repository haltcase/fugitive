include ../base

import strformat
from algorithm import sort
from os import existsFile, moveFile, tryRemoveFile
from sequtils import keepIf
from times import getDateStr

import tempfile

type
  Header = tuple[kind: string, scope: string, desc: string]
  Commit = object
    hash: string
    header: Header
    body: string

const
  itemSeparator = "#&<2#@~#2>&#"
  commitSeparator = "#++-~-~2~-~-++#"
  commitFormatParts = ["%H", "%s", "%b"]
  commitFormat = commitFormatParts.join(itemSeparator)
  cmdGetTags = "git describe --tags --abbrev=0"
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
  }.toTable
  usageMessage = """
  Usage: fugitive changelog [file] [--tag|-t:<tag>] [--overwrite|-o] [--no-anchor]

  Write the list of all changes since the last git tag. Uses the
  Angular commit conventions to categorize and filter commits, ie.
  internally focused changes will not be listed.

  If `file` is not provided, changes will be written to `stdout`.

  When the `overwrite` flag is absent, changes will be prepended
  to `file` if it exists. Has no effect when writing to `stdout`.

  HTML anchor elements are added for linking purposes but can be
  disabled by providing the `--no-anchor` flag.

  See the Angular contributor guidelines for more information about
  the commit conventions: https://git.io/f49fN

  Example:

    fugitive changelog changelog.md --tag:v1.1.0
  """

proc parseHeader (header: string): Header =
  let openParen = header.find('(')
  let closeParen = header.find(')')

  if openParen > -1:
    result = (
      kind: header[0..<openParen].strip,
      scope: header[openParen + 1..<closeParen].strip,
      desc: header[closeParen + 2..header.high].strip
    )
  else:
    let colon = header.find(':')
    result = (
      kind: header[0..<colon].strip,
      scope: "",
      desc: header[colon + 1..header.high].strip
    )

proc parseCommitList (commitList: string): seq[Commit] =
  result = @[]
  for commitRaw in commitList.split commitSeparator:
    if commitRaw.strip == "": continue

    var commit = Commit()
    let parts = commitRaw.split(itemSeparator, 3)
    commit.hash = parts[0].strip
    commit.header = parts[1].parseHeader
    commit.body = parts[2].strip
    result.add commit

proc shouldPrint (commit: Commit): bool =
  commitKinds[commit.header.kind].print

proc render (commit: Commit, repoUrl: string): string =
  result = "* "
  if commit.header.scope != "":
    result &= "**" & commit.header.scope & ":** "

  result &= commit.header.desc

  let shortHash = commit.hash[0..6]

  result &= &" ([`{shortHash}`]({repoUrl}/commit/{commit.hash}))"

proc sortCommits (x, y: Commit): int =
  cmp(x.header.kind, y.header.kind)

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
    if "overwrite" in opts or "o" in opts:
      result = (args[0].open(fmWrite), args[0], true)
    else:
      let (fd, name) = mkstemp(mode = fmWrite)
      result = (fd, name, false)
  else:
    result = (stdout, "", false)

proc changelog* (args: Arguments, opts: Options) =
  if not isGitRepo(): fail errNotRepo

  if "help" in opts or "h" in opts:
    echo "\n" & usageMessage
    quit 0

  let (lastTag, code) = execCmdEx cmdGetTags
  let rev = if code != 0: "" else: lastTag.strip & "..HEAD"

  let (commits, c) = execCmdEx cmdGetCommits & rev
  if c != 0:
    if rev == "":
      print "No commits found."
    else:
      print "No changes since " & lastTag.strip & "."

    quit 0

  var commitList = commits.parseCommitList
  commitList.sort(sortCommits)
  commitList.keepIf(shouldPrint)

  let newTag =
    if "tag" in opts: opts["tag"]
    elif "t" in opts: opts["t"]
    else: ""

  let repoUrl = getRepoUrl()

  var title = "### "
  if newTag != "":
    title &= &"[`{newTag}`]({repoUrl}/compare/{lastTag.strip}...{newTag}) ("

  title &= getDateStr()
  if newTag != "": title &= ")"
  title &= "\n\n"

  let (file, path, overwrite) = selectFile(args, opts)

  if "no-anchor" notin opts:
    file.output &"<a name=\"{newTag}\"></a>\n"

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

    print "changelog updated"
  else:
    close file
