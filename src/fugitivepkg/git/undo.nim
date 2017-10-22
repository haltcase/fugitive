include ../base

proc undo* (args: Arguments, opts: Options) =
  if not isGitRepo(): fail errNotRepo
  let num = if args.len >= 1: args[0] else: ""
  let strategy = if "hard" in opts: "hard" else: "soft"
  let (res, code) = execCmdEx "git reset --" & strategy & " HEAD^" & num

  if code == 0:
    print "Last commit removed."
    quit 0

  if res.startsWith "fatal: ambiguous argument 'HEAD^'":
    fail "Could not undo. Is this a new repo with no commits?"
  else:
    fail res
