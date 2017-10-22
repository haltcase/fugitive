include ../base

const
  cmdUnlockFile = "git update-index --no-skip-worktree $1"

proc unlock* (args: Arguments, opts: Options) =
  if not isGitRepo():
    fail errNotRepo

  if args.len < 1:
    fail "File name(s) must be provided."

  let (res, code) = execCmdEx cmdUnlockFile % [args.join " "]
  if code != 0: fail res.strip

  print "File(s) unlocked."
