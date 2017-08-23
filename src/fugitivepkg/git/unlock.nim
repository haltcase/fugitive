include ../base

const
  UNLOCK = "git update-index --no-skip-worktree $1"

proc unlock* (args: Arguments, opts: Options) =
  if not isGitRepo():
    fail NOT_REPO

  if args.len < 1:
    fail "File name(s) must be provided."

  let (res, code) = execCmdEx UNLOCK % [args.join " "]
  if code != 0: fail res.strip

  print "File(s) unlocked."
