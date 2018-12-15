include ../base

import gara, unpack

const
  usageMessage = """
  Usage: fugitive config [key] [value] [--remove|-r]

  Manage fugitive settings or customizations. If no arguments are provided,
  the config filepath will be displayed. If `key` is provided without a
  `value`, the value of that key will be shown. If both `key` & `value`
  are provided, the key will be set to the given value.

  If the `remove`/`r` flag is provided, the given `key` will be deleted.

  Examples:

    fugitive config github.username           # show existing value
    fugitive config github.username citycide  # add or update value
    fugitive config github.username -r        # remove the setting
  """

  knownSettings* = {
    "terminal_colors": "bool",
    "github.username": "string"
  }.toTable

proc parseKey (key: string): tuple[section, key: string] =
  result = match key.split('.', 1):
    @[@section, @field]: (section.strip, field.strip)
    @[@field]: ("user", field.strip)
    _: ("", "")

proc config* (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & usageMessage
    quit 0

  if args.len == 0:
    echo configFilePath
    quit 0

  [section, key] <- args[0].parseKey

  if key == "":
    fail "Invalid key"

  if args.len == 1:
    if getOptionValue(opts, "r", "remove", bool):
      remConfigValue(section, key)
      print &"Removed {section}.{key}"
      quit 0

    let res = getConfigValue(section, key)
    print &"{section}.{key} = {res}"
  elif args.len >= 2:
    let value = args[1..^1].join(" ")

    if knownSettings.getOrDefault(key, "string") == "bool":
      try:
        discard value.parseBool
      except:
        fail "{key} must be a parseable as a boolean value (true, no, on, off, etc)."

    let res = setConfigValue(section, key, value)
    print &"Value updated ({section}.{key} = {res})"
