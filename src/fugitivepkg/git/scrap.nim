include ../base

import strformat
from sequtils import mapIt

const
  usageMessage = """
  Usage: fugitive scrap <...files> [--all|-a]

  Discard local changes to the specified files, or to all files if the `all`
  (or `-a`) flag is provided. This provides a unified interface for the git
  commands `git checkout -- <...files>` and `git reset --hard`.

  Note: be careful as this action can be difficult to reverse.

  Example:

    fugitive scrap src/foo.nim src/bar.nim
  """

proc scrap* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo(): fail errNotRepo

  if getOptionValue(opts, "a", "all", bool):
    let (res, code) = execCmdEx "git reset --hard"
    if code == 0:
      print "All local changes discarded"
      quit 0
    else:
      fail res

  argCheck(args, 1, "File names required.")

  let (res, code) = execCmdEx "git checkout -- " & args.mapIt(&"'{it}'").join(" ")
  if code == 0:
    print "Local changes to files discarded"
    quit 0
  else:
    fail res
