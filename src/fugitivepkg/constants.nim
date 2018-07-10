import os
import strformat

const
  configFilePath* = getConfigDir() / "fugitive.ini"

# error messages

const
  errNotRepo* = "Must be run in a git repository."
  errNoName* = "You must provide a username."

# usage strings

# TODO: when upgrading to nim 0.18.1+ these might be able to be
# dropped in favor of new procs in the `terminal` module
const reset = "\e[0m"
proc yellow* (s: string): string = "\e[33m" & s & reset
proc bold* (s: string): string = "\e[1m" & s & reset

const
  project = "fugitive".yellow
  usage = "Usage".bold
  commands = "Commands".bold
  options = "Options".bold
  help* = &"""

  {usage}: {project} [command] [...args] [...options]

  {commands}:
    age       <username>           Display the age of the profile for <username>
    alias     [name [--remove|-r]] [expansion]
                                   List, add, or remove git aliases
    config    [key] [value] [--remove|-r]
                                   Set, update, or remove fugitive settings
    changelog [file] [--tag|-t:<tag>] [--overwrite|-o] [--no-anchor] [--init]
                                   Write changes since last tag to file or stdout
    clone     <...repos>           Alias for `fugitive mirror`
    install   [--override|-o] [--force|-y]
                                   Alias various fugitive commands as git subcommands
    lock      <...files>           Prevent changes to the specified files from being tracked
    mirror    <...repos>           Wrapper around `git clone` with various URL shorthands
    open      [repo]               Open the current or specified repository's homepage
    repos     <username>           Display the number of public repos for <username>
    summary                        Summarize git repository statistics
    undo      [#] [--hard|-h]      Undo the last commit ( or last # commits )
    uninstall                      Remove git aliases added by `install`
    unlock    <...files>           Resume tracking changes to these locked files
    unstage   <...files>           Remove files from the git stage area

  {options}:
    --help, -h       Show this help message
    --version, -v    Output the {project} version number
  """
