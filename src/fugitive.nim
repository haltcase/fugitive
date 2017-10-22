import asyncdispatch
import os
import osproc
import parseopt2
import strutils
import tables

import colorize

import fugitivepkg/[constants, github, types]
import fugitivepkg/common/cli
import fugitivepkg/git/[
  alias,
  install,
  lock,
  mirror,
  open,
  summary,
  undo,
  uninstall,
  unlock,
  unstage
]

proc getPkgPath (): static[string] =
  instantiationInfo(fullPaths = true).filename.parentDir.parentDir

when defined(windows) and not defined(cross):
  const pkgPath = getPkgPath() / "fugitive.nimble"
else:
  const pkgPath = getPkgPath() & "/fugitive.nimble"

const version =
  pkgPath
  .staticRead
  .splitLines()[0]
  .split('=')[1]
  .strip(chars = {'"'} + Whitespace)

proc parseInput (): Input =
  var args: seq[string] = @[]
  var opts = initTable[string, string]()
  for kind, key, val in getopt():
    of cmdArgument: args.add key.toLowerAscii
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        echo HELP
        quit 0
      of "version", "v":
        echo "fugitive v" & version
        quit 0
      else: opts[key.toLowerAscii] = val.toLowerAscii
    else: discard

  result = (args, opts)

proc main (command: string, args: Arguments, opts: Options): int =
  case command
  of "age":
    argCheck(args, 1, NO_NAME)
    print "$1 profile age: $2" % [args[0], waitFor getUserAge args[0]]
  of "alias": alias(args, opts)
  of "install": install(args, opts)
  of "lock": lock(args, opts)
  of "mirror", "clone": mirror(args, opts)
  of "open": open(args, opts)
  of "repos":
    argCheck(args, 1, NO_NAME)
    let count = waitFor getRepoCount args[0]
    print "$1 has $2 public repositories" % [args[0], $count]
  of "summary": summary(args, opts)
  of "undo": undo(args, opts)
  of "uninstall": uninstall(args, opts)
  of "unlock": unlock(args, opts)
  of "unstage": unstage(args, opts)
  else: discard

  result = 0

when isMainModule:
  let (args, opts) = parseInput()
  if args.len == 0 and opts.len == 0:
    echo HELP
    quit 0

  quit main(args[0], args[1..args.high], opts)
