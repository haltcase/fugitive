include ../base

const
  cmdUnlockFile = "git update-index --no-skip-worktree "
  usageMessage = """
  Usage: fugitive unlock <...files>

  Resume tracking changes to the specified files after having
  previously run `fugitive lock <...files>`.
  """

proc unlock* (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo():
    fail errNotRepo

  if args.len < 1:
    fail "File name(s) must be provided."

  let (res, code) = execCmdEx cmdUnlockFile & args.join(" ")
  if code != 0: fail res.strip

  print "File(s) unlocked."
