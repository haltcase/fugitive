import os
import parsecfg
import strformat
import tables
from strutils import join, split, strip

import ./cli
import ../constants
import ../types

const
  usageMessage = """
  Usage: fugitive config [key] [value] [--remove|-r]

  Manage fugitive settings or customizations. If no arguments are provided,
  the config filepath will be displayed. If `key` is provided without a
  `value`, the value of that key will be shown. If both `key` & `value`
  are provided, the key will be set to the given value.

  If the `remove`/`r` flag is provided, the given `key` will be deleted.

  Example:

    fugitive config github.username           # show existing value
    fugitive config github.username citycide  # add or update value
    fugitive config github.username -r        # remove the setting
  """

proc loadSettings* (): Config =
  getConfigDir().createDir()
  try:
    result = loadConfig(configFilePath)
  except IOError:
    var cfg = newConfig()
    cfg.writeConfig(configFilePath)
    result = cfg

proc getConfigValue* (section, key: string): string =
  let cfg = loadSettings()
  result = cfg.getSectionValue(section, key)

proc setConfigValue* (section, key, value: string): string =
  var cfg = loadSettings()
  cfg.setSectionKey(section, key, value)
  cfg.writeConfig(configFilePath)
  result = value

proc remConfigValue* (section, key: string) =
  var cfg = loadConfig(configFilePath)
  cfg.delSectionKey(section, key)
  cfg.writeConfig(configFilePath)

proc parseKey (key: string): tuple[section, key: string] =
  let keys = key.split('.', 1)

  case keys.len
  of 1: return ("user", keys[0].strip)
  of 2: return (keys[0].strip, keys[1].strip)
  else: discard

proc config* (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & usageMessage
    quit 0

  if args.len == 0:
    echo configFilePath
    quit 0

  let (section, key) = args[0].parseKey

  if key == "":
    fail "Invalid key"

  if args.len == 1:
    if "r" in opts or "remove" in opts:
      remConfigValue(section, key)
      print &"Removed {section}.{key}"
      quit 0

    let res = getConfigValue(section, key)
    print &"{section}.{key} = {res}"
  elif args.len >= 2:
    let value = args[1..^1].join(" ")
    let res = setConfigValue(section, key, value)
    print &"Value updated ({section}.{key} = {res})"

