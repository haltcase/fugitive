include ../base

const
  cmdUnlockFile = "git update-index --no-skip-worktree "
  usageMessage = """
  Usage: fugitive unlock <...files>

  Resume tracking changes to the specified files after having
  previously run `fugitive lock <...files>`.
  """

proc unlock* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo():
    fail errNotRepo

  argCheck(args, 1, "File name(s) must be provided.")

  match execCmdEx cmdUnlockFile & args.join(" "):
    (_, 0): print "File(s) unlocked."
    (@res, _): fail res.strip
