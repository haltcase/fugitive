include ../base

import strformat

const
  usageMessage = """
  Usage: fugitive unstage <...files> [--all|-a]

  Remove the specified files from the git staging area. If the `--all`
  (or `-a`) flag is provided, all currently staged files are unstaged.
  Directories are recursively unstaged.

  Example

    fugitive unstage src/foo.nim src/bar.nim
    fugitive unstage --all
  """

proc unstage* (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo(): fail errNotRepo

  if "a" in opts or "all" in opts:
    let (res, code) = execCmdEx "git reset"
    if code == 0:
      print "Files unstaged"
      quit 0

  argCheck(args, 1, "File names required")

  let (res, code) = execCmdEx "git reset HEAD " & args.join(" ")

  if code == 0:
    print "Files unstaged"
    quit 0

  if res.startsWith "fatal: ambiguous argument 'HEAD'":
    # we're probably in a new repo with no commits
    # so thanks to git's highly unpredictable interface, we need
    # to use a totally different command to remove staged files
    # but unlike `git add`, `git rm` only accepts a single file
    # at a time, so we'll have to run a separate command for each one
    var good = 0
    for arg in args:
      let (res, code) = execCmdEx &"git rm --cached -r {arg}"
      if code != 0:
        failSoft &"Could not unstage '{arg}'\n{res.indent(2)}"
      else:
        inc good

    if good == 0:
      fail &"Failed to unstage {args.len} files"
    else:
      print &"Files unstaged ({good} of {args.len})"
  else:
    fail res
