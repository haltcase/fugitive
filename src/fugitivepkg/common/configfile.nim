import os, parsecfg

import ../constants

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
