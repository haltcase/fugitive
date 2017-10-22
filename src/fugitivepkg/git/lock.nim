include ../base

const
  cmdLockFile = "git update-index --skip-worktree $1"

proc lock* (args: Arguments, opts: Options) =
  if not isGitRepo():
    fail errNotRepo

  if args.len < 1:
    fail "File name(s) must be provided."

  let (res, code) = execCmdEx LOCK % [args.join " "]
  if code != 0: fail res.strip

  print "File(s) locked."
