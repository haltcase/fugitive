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

  var good = 0
  var untracked: seq[string] = @[]
  for arg in args:
    let (_, code) = execCmdEx cmdLockFile % arg
    if code == 0: good.inc
    else:
      let (_, err) = execCmdEx "git ls-files --error-unmatch " & arg
      if err == 1: untracked.add arg

  if good > 0:
    print "File(s) locked. (" & $good & " of " & $args.len & ")"
    if untracked.len > 0:
      echo "Could not lock untracked files:\n\n  " &
        untracked.join "\n  "
      echo ""
  else:
    fail "Untracked files cannot be locked."
