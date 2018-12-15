from tables import Table

type
  Command* {.pure.} = enum
    Alias
    Changelog
    Config
    Install
    Lock
    Mirror
    Open
    Profile
    Release
    Scrap
    Summary
    Undo
    Uninstall
    Unlock
    Unstage
  Arguments* = seq[string]
  Options* = Table[string, string]
  Input* = tuple[args: Arguments, opts: Options]
