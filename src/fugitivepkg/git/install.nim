include ../base

from ./alias import createAlias

const
  INFO = """
  This will alias various fugitive commands as git subcommands,
  which means for example that these would be equivalent:

    git unstage [...files]
    fugitive unstage [...files]

  Be aware this can conflict with other tools that may do the same.
  Nothing will be overridden unless you pass the --override (-o) flag.
  """.strip

  COMMANDS* = [
    "alias",
    "lock",
    "mirror",
    "open",
    "summary",
    "undo",
    "unlock",
    "unstage"
  ]

proc install* (args: Arguments, opts: Options) =
  let noPrompt = "y" in opts or "force" in opts
  if not noPrompt and not prompt(INFO):
    print "Install cancelled."
    quit 0

  var shouldOverwrite = false
  if "o" in opts or "override" in opts:
    if noPrompt:
      shouldOverwrite = true
      echo "  fugitive will override existing aliases."
    else:
      shouldOverwrite = prompt """
      This will override existing aliases, possibly from other tools.
      """.strip

  for _, command in COMMANDS:
    let value = "!fugitive " & command
    let (existing, _) = execCmdEx "git config --global alias." & command
    let stripped = existing.strip
    if stripped == value:
      # this alias has already been set
      continue
    elif stripped != "" and not shouldOverwrite:
      # user hasn't allowed overriding existing aliases
      continue

    let (_, code) = command.createAlias value
    if code != 0:
      failSoft "Could not set alias for '" & command & "'"

  print "Aliases installed. Use `fugitive uninstall` to remove them."
