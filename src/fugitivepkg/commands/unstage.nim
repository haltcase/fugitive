include ../base

const
  usageMessage = """
  Usage: fugitive unstage <...files> [--all|-a]

  Remove the specified files from the git staging area. If the `--all`
  (or `-a`) flag is provided, all currently staged files are unstaged.
  Directories are recursively unstaged.

  Examples:

    fugitive unstage src/foo.nim src/bar.nim
    fugitive unstage --all
  """

proc unstage* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo(): fail errNotRepo

  if getOptionValue(opts, "a", "all", bool):
    if (execCmdEx "git reset").exitCode == 0:
      print "Files unstaged"
      quit 0

  argCheck(args, 1, "File names required")

  [res, code] <- execCmdEx "git reset HEAD " & args.join(" ")

  if code == 0:
    print "Files unstaged"
    quit 0

  if not res.startsWith "fatal: ambiguous argument 'HEAD'":
    fail res

  # we're probably in a new repo with no commits
  # so thanks to git's highly unpredictable interface, we need
  # to use a totally different command to remove staged files
  # but unlike `git add`, `git rm` only accepts a single file
  # at a time, so we'll have to run a separate command for each one
  var good = 0
  for arg in args:
    match execCmdEx &"git rm --cached -r {arg}":
      (_, 0): inc good
      (@res, _): failSoft &"Could not unstage '{arg}'\n{res.indent(2)}"

  if good == 0:
    fail &"Failed to unstage {args.len} files"
  else:
    print &"Files unstaged ({good} of {args.len})"
