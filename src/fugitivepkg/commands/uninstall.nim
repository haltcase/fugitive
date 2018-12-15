include ../base

from ./alias import removeAlias
from ./install import commandsToAlias

const
  helpMessage = """
  This will remove fugitive commands as git aliases. Existing aliases
  that were not set by fugitive will be unaffected.
  """.strip
  usageMessage = &"""
  Usage: fugitive uninstall

  {helpMessage}
  """

proc uninstall* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not prompt(helpMessage):
    print "Uninstall cancelled."
    quit 0

  for command in commandsToAlias:
    let value = "!fugitive " & command
    [existing] <- execCmdEx "git config --global alias." & command

    if existing.strip == value:
      if command.removeAlias.exitCode != 0:
        failSoft &"Could not remove alias for '{command}'"
    else:
      continue

  print "Aliases uninstalled. Use `fugitive install` to restore them."
