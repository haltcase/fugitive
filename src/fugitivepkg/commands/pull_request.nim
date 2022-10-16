include ../base

import pegs

const
  cmdGetPrs = "git for-each-ref refs/heads/pr/* --format='%(refname)'"
  cmdCleanPr = "git branch -D $branch"
  cmdFetch = "git fetch -fu $remote pull/$id/head:$branch"
  cmdCheckout = "git checkout $branch"
  cmdConfigMerge = "git config --local --replace branch.$branch.merge refs/pull/$id/head"
  cmdConfigRemote = "git config --local --replace branch.$branch.remote $remote;"
  usageMessage = """
  Usage: fugitive pr [clean|<id>|<url>] [--remote|-r:<name>]

  Switch the local branch to a GitHub pull request by number or URL.
  This can pull histories of repositories other than the current one
  if explicitly instructed to.

  Examples:

    # clone a pull request from origin
    fugitive pr 116

    # or from another remote
    fugitive pr 116 -r:upstream

    # or from a specific GitHub URL
    fugitive pr https://github.com/haltcase/glob/pull/19

    # or from other repositories using GitHub shorthands
    fugitive pr haltcase/glob/pull/19
    fugitive pr glob/pull/19

    # delete previously cloned branches
    fugitive pr clean
  """

let
  patternId = peg"^{\d+}$"
  patternFullUrl = peg"^{'http'('s'?)'://'[^/]+}'/'{\w+}'/'{\w+}'/pull/'{\d+}$"
  patternShortUrl = peg"^{\w+}'/'{\w+}'/pull/'{\d+}$"
  patternInferUrl = peg"^{\w+}'/pull/'{\d+}$"

proc pullRequest* (args: Arguments, opts: Options) =
  if opts.get("h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  args.require(1, "Pull request #/URL or subcommand required")

  [spec] <- args

  if spec == "clean":
    [res, code] <- execCmdEx cmdGetPrs

    if code != 0:
      fail "Couldn't list local pull request branches\p\p" & res.indent(2)

    var good, total: int
    for line in res.splitLines:
      let branchName = line.strip(chars = {'\''}).removePrefix("refs/heads/")
      if branchName.len == 0: continue
      inc total

      match execCmdEx cmdCleanPr % ["branch", branchName]:
        (_, 0):
          inc good
        (@res2, _):
          failSoft &"Couldn't remove pull request branch '{branchName}'\p\p{res2.indent(2)}"

    print &"Cleaned pull request branches ({good} of {total})"
    quit 0

  var id: string
  var remote = opts.get("r", "remote")

  if spec =~ patternId:
    [id] <-- matches
    if remote.len == 0: remote = "origin"
  elif spec =~ patternInferUrl:
    id = matches[1]
    if remote.len == 0:
      remote = match getGitUsername():
        Some(@name): &"https://github.com/{name}/{matches[0]}.git"
        _: fail "Could not infer GitHub username"
  elif spec =~ patternShortUrl:
    id = matches[2]
    if remote.len == 0:
      remote = &"https://github.com/{matches[0]}/{matches[1]}.git"
  elif spec =~ patternFullUrl:
    id = matches[3]
    if remote.len == 0:
      remote = &"{matches[0]}/{matches[1]}/{matches[2]}.git"
  else:
    fail "Invalid pull request # or URL specifier"

  let branch = &"pr/{id}"

  [res, code] <-
    execCmdEx(cmdFetch % ["remote", remote, "id", id, "branch", branch]) &&
    execCmdEx(cmdCheckout % ["branch", branch]) &&
    execCmdEx(cmdConfigMerge % ["branch", branch, "id", id]) &&
    execCmdEx(cmdConfigRemote % ["branch", branch, "remote", remote])

  if code != 0:
    fail res
