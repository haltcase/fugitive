import strutils

import colorize

proc print* (msg: string) =
  echo "\n✓ ".fgGreen & msg & "\n"

proc fail* (msg: string) =
  echo "\n✗ ".fgRed & msg & "\n"
  quit 1

proc failSoft* (msg: string) =
  echo "\n✗ ".fgRed & msg

proc prompt* (msg: string): bool =
  echo "\n⁉  ".fgBlue & msg & "\n" & "  Do you want to continue? [y/N]"
  let response = stdin.readLine.normalize
  result = response == "y" or response == "yes"

proc promptResponse* (msg: string): string =
  echo "\n⁉  ".fgGreen & msg & "\n"
  result = stdin.readLine.strip

proc argCheck* (args: seq[string], req: int, msg: string) {.discardable.} =
  if args.len < req: fail msg