import asyncdispatch, options, os, osproc, parseopt, strformat, strutils, tables
import gara
import unpack except unpack

import fugitivepkg/[constants, github, types]
import fugitivepkg/common/[cli, configfile]
import fugitivepkg/commands/[
  alias,
  changelog,
  config,
  install,
  lock,
  mirror,
  open,
  release,
  scrap,
  summary,
  undo,
  uninstall,
  unlock,
  unstage
]

const fugitiveVersion {.strdefine.} = "(development build)"

proc showHelp () =
  let args = if isColorEnabled(): helpInfoColor else: helpInfo
  echo helpTemplate % args

proc parseInput (): Input =
  var args: seq[string]
  var opts = initTable[string, string]()
  var idx = -1
  for kind, key, val in getopt():
    inc idx
    case kind
    of cmdArgument: args.add(key)
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        if idx == 0:
          showHelp()
          quit 0
        else:
          opts["help"] = val
      of "version", "v":
        echo "fugitive " & fugitiveVersion
        quit 0
      else: opts[key] = val
    else: discard

  result = (args, opts)

proc ageCmd (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & """
    Usage: fugitive age <username>

    Display the GitHub profile age for the given <username>.
    """
    quit 0

  argCheck(args, 1, errNoName)

  match waitFor args[0].getUserAge:
    Some(@n): print &"{args[0]} profile age: {n}"
    _: fail &"Could not retrieve profile age for '{args[0]}', does this user exist?"

proc reposCmd (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & """
    Usage: fugitive repos <username>

    Display the number of public GitHub repos for <username>.
    """
    quit 0

  argCheck(args, 1, errNoName)

  match waitFor args[0].getRepoCount:
    Some(@n): print &"{args[0]} has {n} public repositories"
    _: fail &"Could not retrieve repo count for '{args[0]}', does this user exist?"

proc main (command: Command, args: Arguments, opts: Options): int =
  match command:
    Command.Age: ageCmd(args, opts)
    Command.Alias: alias(args, opts)
    Command.Changelog: changelog(args, opts)
    Command.Config: config(args, opts)
    Command.Install: install(args, opts)
    Command.Lock: lock(args, opts)
    Command.Mirror: mirror(args, opts)
    Command.Open: open(args, opts)
    Command.Release: release(args, opts)
    Command.Repos: reposCmd(args, opts)
    Command.Scrap: scrap(args, opts)
    Command.Summary: summary(args, opts)
    Command.Undo: undo(args, opts)
    Command.Uninstall: uninstall(args, opts)
    Command.Unlock: unlock(args, opts)
    Command.Unstage: unstage(args, opts)
    _: fail &"unknown command '{command}'"

  result = 0

proc parseCommand (str: string): Command =
  result = match str:
    "age": Age
    "alias": Alias
    "changelog": Changelog
    "config": Config
    "install": Install
    "lock": Lock
    "mirror" or "clone": Mirror
    "open": Open
    "release": Release
    "repos": Repos
    "scrap": Scrap
    "summary": Summary
    "undo": Undo
    "uninstall": Uninstall
    "unlock": Unlock
    "unstage": Unstage
    _: fail &"unknown command '{str}'"

when isMainModule:
  [args, opts] <- parseInput()
  if args.len == 0 and opts.len == 0:
    showHelp()
    quit 0

  # check whether git is accessible
  [res, code] <- execCmdEx "git --version"
  if code != 0 or res.strip == "":
    fail """
    git doesn't seem to be installed. Please install it or
    ensure that it has been added to your PATH.
    """.strip

  let cmd = args[0].parseCommand
  quit main(cmd, args[1..^1], opts)
