from tables import Table

type
  Command* {.pure.} = enum
    Age
    Alias
    Changelog
    Config
    Install
    Lock
    Mirror
    Open
    Release
    Repos
    Scrap
    Summary
    Undo
    Uninstall
    Unlock
    Unstage
  Arguments* = seq[string]
  Options* = Table[string, string]
  Input* = tuple[args: Arguments, opts: Options]
