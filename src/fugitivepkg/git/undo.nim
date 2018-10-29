include ../base

const
  usageMessage = """
  Usage: fugitive undo [#] [--hard|-H]

  Undo the latest commit or the latest <#> commits if provided.
  By default the changes in the commit are preserved but can be
  discarded by providing the --hard (-H) flag.

  Example:

    fugitive undo       # roll back the most recent commit
    fugitive undo 3     # roll back the 3 most recent commits
  """

proc undo* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo(): fail errNotRepo

  let num = if args.len >= 1: args[0] else: ""
  let strategy = if getOptionValue(opts, "H", "hard", bool): "hard" else: "soft"
  let (res, code) = execCmdEx "git reset --" & strategy & " HEAD^" & num

  if code == 0:
    print "Last commit removed."
    quit 0

  if res.startsWith "fatal: ambiguous argument 'HEAD^'":
    fail "Could not undo. Is this a new repo with no commits?"
  else:
    fail res
