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
    PullRequest
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
  CommandResult* = tuple[output: string, exitCode: int]
