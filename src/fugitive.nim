import asyncdispatch, options, os, osproc, parseopt, strformat, strutils, tables

import fugitivepkg/[constants, github, types]
import fugitivepkg/common/[cli, config]
import fugitivepkg/git/[
  alias,
  changelog,
  install,
  lock,
  mirror,
  open,
  scrap,
  summary,
  undo,
  uninstall,
  unlock,
  unstage
]

const fugitiveVersion {.strdefine.} = "(development build)"

proc parseInput (): Input =
  var args: seq[string] = @[]
  var opts = initTable[string, string]()
  var idx = -1
  for kind, key, val in getopt():
    inc idx
    case kind
    of cmdArgument: args.add(key.toLowerAscii)
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        if idx == 0:
          echo help
          quit 0
        else:
          opts["help"] = val
      of "version", "v":
        echo "fugitive " & fugitiveVersion
        quit 0
      else: opts[key.toLowerAscii] = val.toLowerAscii
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
  let age = waitFor args[0].getUserAge
  if age.isSome:
    print &"{args[0]} profile age: {age.get}"
  else:
    fail &"Could not retrieve profile age for '{args[0]}', does this user exist?"

proc reposCmd (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & """
    Usage: fugitive repos <username>

    Display the number of public GitHub repos for <username>.
    """
    quit 0

  argCheck(args, 1, errNoName)
  let count = waitFor args[0].getRepoCount
  if count.isSome:
    print &"{args[0]} has {count.get} public repositories"
  else:
    fail &"Could not retrieve repo count for '{args[0]}', does this user exist?"

proc main (command: string, args: Arguments, opts: Options): int =
  case command
  of "age": ageCmd(args, opts)
  of "alias": alias(args, opts)
  of "changelog": changelog(args, opts)
  of "config": config(args, opts)
  of "install": install(args, opts)
  of "lock": lock(args, opts)
  of "mirror", "clone": mirror(args, opts)
  of "open": open(args, opts)
  of "repos": reposCmd(args, opts)
  of "scrap": scrap(args, opts)
  of "summary": summary(args, opts)
  of "undo": undo(args, opts)
  of "uninstall": uninstall(args, opts)
  of "unlock": unlock(args, opts)
  of "unstage": unstage(args, opts)
  else: fail &"unknown command '{command}'"

  result = 0

when isMainModule:
  let (args, opts) = parseInput()
  if args.len == 0 and opts.len == 0:
    echo help
    quit 0

  # check whether git is accessible
  let (res, code) = execCmdEx "git --version"
  if code != 0 or res.strip == "":
    fail """
    git doesn't seem to be installed. Please install it or
    ensure that it has been added to your PATH.
    """.strip

  quit main(args[0], args[1..^1], opts)
