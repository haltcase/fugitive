import os, terminal

const
  configFilePath* = getConfigDir() / "fugitive.ini"

# error messages

const
  errNotRepo* = "Must be run in a git repository."
  errNoName* = "You must provide a username."

# usage strings

proc yellow* (s: static[string]): string =
  ansiForegroundColorCode(fgYellow, false) & s & ansiResetCode

proc bold* (s: static[string]): string =
  ansiStyleCode(styleBright) & s & ansiResetCode

const
  project = "fugitive"
  usage = "Usage"
  commands = "Commands"
  options = "Options"
  helpInfo* = [project, usage, commands, options]
  helpInfoColor* = [project.yellow, usage.bold, commands.bold, options.bold]
  helpTemplate* = """

  $2: $1 [command] [...args] [...options]

  $3:
    alias     [name [--remove|-r]] [expansion]
                                   List, add, or remove git aliases
    config    [key] [value] [--remove|-r]
                                   Set, update, or remove fugitive settings
    changelog [file] [--tag|-t:<tag>] [--last-tag|-l:<tag>] [--overwrite|-o]
              [--no-anchor] [--no-title] [--no-divider] [--init]
                                   Write a list of changes since last tag or between two tags
    clone     <...repos>           Alias for `fugitive mirror`
    install   [--override|-o] [--force|-y]
                                   Alias various fugitive commands as git subcommands
    lock      <...files>           Prevent changes to the specified files from being tracked
    mirror    <...repos>           Wrapper around `git clone` with various URL shorthands
    open      [repo]               Open the current or specified repository's homepage
    profile   [username]           View a summary of a GitHub user profile
    release   <tag> [--repo|-r:<repo>] [--file|-f:<filepath>] [--description|-d:<desc>]
              [--desc-file|-D:<filepath>] [--draft|-N] [--prerelease|-p]
              [--target-commit|-T:<commitish>]
                                   Create a GitHub release and/or upload assets to a release
    scrap     <...files>  [--all|-a]
                                   Discard local changes to the specified files
    summary                        Summarize git repository statistics
    undo      [#] [--hard|-h]      Undo the last commit ( or last # commits )
    uninstall                      Remove git aliases added by `install`
    unlock    <...files>           Resume tracking changes to these locked files
    unstage   <...files> [--all|-a]
                                   Remove files from the git stage area

  $4:
    --help, -h       Show this help message
    --version, -v    Output the $1 version number
  """
