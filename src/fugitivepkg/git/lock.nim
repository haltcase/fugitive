include ../base

const
  cmdLockFile = "git update-index --skip-worktree $1"
  usageMessage = """
  Usage: fugitive lock <...files>

  Prevent changes to the specified file(s) from being tracked.
  This can help you avoid pushing changes to files that should
  not be modified in source control, while still allowing you
  to modifying them locally.

  Example:

    fugitive lock fixtures/test.db
  """

proc lock* (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo():
    fail errNotRepo

  if args.len < 1:
    fail "File name(s) must be provided."

  let (res, code) = execCmdEx LOCK % [args.join " "]
  if code != 0: fail res.strip

  print "File(s) locked."
