from strutils import normalize, strip

import terminal

proc printImpl (icon, msg: string, color: ForegroundColor) =
  stdout.setForegroundColor(fgGreen)
  stdout.write(icon)
  resetAttributes()
  echo msg

proc print* (msg: string) =
  printImpl("\n✓ ", msg, fgGreen)
  echo "\n"

proc fail* (msg: string) =
  printImpl("\n✗ ", msg, fgRed)
  echo "\n"
  quit 1

proc failSoft* (msg: string) =
  printImpl("\n✗ ", msg, fgRed)

proc prompt* (msg: string): bool =
  printImpl("\n⁉  ", msg & "\n" & "  Do you want to continue? [y/N]", fgBlue)
  let response = stdin.readLine.normalize
  result = response == "y" or response == "yes"

proc promptResponse* (msg: string): string =
  printImpl("\n⁉  ", msg, fgGreen)
  echo "\n"
  result = stdin.readLine.strip

proc argCheck* (args: seq[string], req: int, msg: string) {.discardable.} =
  if args.len < req: fail msg