include ../base

import unpack

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
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo():
    fail errNotRepo

  argCheck(args, 1, "File name(s) must be provided.")

  var good = 0
  var untracked: seq[string]
  for arg in args:
    if (execCmdEx cmdLockFile % arg).exitCode == 0:
      inc good
    else:
      { exitCode } <- execCmdEx "git ls-files --error-unmatch " & arg
      if exitCode == 1: untracked.add arg

  if good > 0:
    print &"File(s) locked. ({good} of {args.len})"
    if untracked.len > 0:
      let failures = untracked.join "\n  "
      echo &"Could not lock untracked files:\n\n  {failures}\n"
  else:
    fail "Untracked files cannot be locked."
