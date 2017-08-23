include ../base

from ./alias import removeAlias
from ./install import COMMANDS

const
  INFO = """
  This will remove fugitive commands as git aliases. Existing aliases
  that were not set by fugitive will be unaffected.
  """.strip

proc uninstall* (args: Arguments, opts: Options) =
  if not prompt(INFO):
    print "Uninstall cancelled."
    quit 0

  for _, command in COMMANDS:
    let value = "!fugitive " & command
    let (existing, _) = execCmdEx "git config --global alias." & command
    let stripped = existing.strip
    if stripped == value:
      let (_, code) = command.removeAlias
      if code != 0:
        failSoft "Could not remove alias for '" & command & "'"
    else:
      continue

  print "Aliases uninstalled. Use `fugitive install` to restore them."
