import os
import parsecfg

import ../constants

proc loadSettings* (): Config =
  getConfigDir().createDir()
  try:
    result = loadConfig(CONFIG_PATH)
  except IOError:
    var cfg = newConfig()
    cfg.writeConfig(CONFIG_PATH)
    result = cfg

proc getConfigValue* (section, key: string): string =
  let cfg = loadSettings()
  result = cfg.getSectionValue(section, key)

proc setConfigValue* (section, key, value: string): string =
  var cfg = loadSettings()
  cfg.setSectionKey(section, key, value)
  cfg.writeConfig(CONFIG_PATH)
  result = value
