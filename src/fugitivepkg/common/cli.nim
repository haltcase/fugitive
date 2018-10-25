import terminal
from strutils import normalize, strip

proc printImpl (icon, msg: string, color: ForegroundColor) =
  stdout.setForegroundColor(color)
  stdout.write(icon)
  resetAttributes()
  stdout.write(msg)

proc print* (msg: string) =
  ## Print a success message with green text.
  printImpl("\n✓ ", msg, fgGreen)
  echo "\n"

proc fail* (msg: string) =
  ## Print a failure message with red text, then quit with error code 1.
  printImpl("\n✗ ", msg, fgRed)
  echo "\n"
  quit 1

proc failSoft* (msg: string) =
  ## Print a failure message with red text.
  printImpl("\n✗ ", msg, fgRed)

proc prompt* (msg: string): bool =
  ## Ask the user for confirmation, where "y" and "yes" result in a ``true``
  ## return value, and anything else results in a ``false`` return value.
  printImpl("\n⁉  ", msg & "\n" & "  Do you want to continue? [y/N]", fgBlue)
  let response = stdin.readLine.normalize
  result = response == "y" or response == "yes"

proc promptResponse* (msg: string): string =
  ## Prompt the user to enter a value which is then returned as a string.
  printImpl("\n⁉  ", msg, fgGreen)
  echo "\n"
  result = stdin.readLine.strip

proc argCheck* (args: seq[string], req: int, msg: string) =
  ## Check that the number of arguments meets a required minimum,
  ## printing a failure message and quitting if it does not.
  if args.len < req: fail msg