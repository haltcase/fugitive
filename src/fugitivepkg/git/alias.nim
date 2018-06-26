include ../base

import future
from sequtils import filter
from terminal import terminalHeight

import ../common/columnize

type
  Longest = tuple[name, expansion: int]
  AliasPair = tuple[name, expansion: string]
  AliasList = tuple[pairs: seq[AliasPair], longest: Longest]
  CmdExResult = tuple[output: TaintedString, exitCode: int]

const
  cmdCreateAlias = "git config --global alias.\"$1\" \"$2\""
  cmdRemoveAlias = "git config --global --unset alias.$1"
  cmdListAliases = "git config --list"

proc getAliasList (pred: (v: string) -> bool = (v: string) => true): AliasList =
  let (res, _) = execCmdEx cmdListAliases
  let filtered = filter(res.splitLines, v => v.startsWith("alias.") and pred(v))

  if filtered.len == 0:
    result = (@[], (0, 0))
  else:
    var longest: Longest = (0, 0)
    var pairs = newSeq[AliasPair](filtered.len)
    for i, val in filtered:
      let segments = split(val, {'.', '='})
      let name = segments[1]
      let expansion = segments[2]

      let nameLength = max(longest.name, name.len)
      let expLength = max(longest.expansion, expansion.len)
      longest = (nameLength, expLength)
      pairs[i] = (name, expansion)

    result = (pairs, longest)

proc createAlias* (name, command: string): CmdExResult =
  result = execCmdEx cmdCreateAlias % [name, command]

proc removeAlias* (name: string): CmdExResult =
  result = execCmdEx cmdRemoveAlias % [name]

proc buildRows (pairs: seq[AliasPair], longest: Longest): seq[string] =
  result = @[]
  for pair in pairs:
    let (name, expansion) = pair
    let spacer = 1.spaces & repeat('.', 6) & 1.spaces
    result.add "$1$2$3" % [
      align(name, longest.name),
      spacer,
      align(expansion, longest.expansion)
    ]

proc alias* (args: Arguments, opts: Options) =
  case args.len
  of 0:
    let (pairs, longest) = getAliasList()
    if pairs.len == 0:
      print "No aliases configured."
      return

    let rows = buildRows(pairs, longest)
    print "Git aliases ->"
    echo rows.columnize(gutter = 4)
  of 1:
    if "remove" in opts or "r" in opts:
      let (_, code) = removeAlias args[0]
      if code != 0:
        fail "Could not remove alias '" & args[0] & "'. Does it exist?"
      else:
        print "Alias '" & args[0] & "' removed"
      return

    let (pairs, longest) = getAliasList(v => v.contains args[0])
    if pairs.len == 0:
      print "No aliases containing '" & args[0] & "'"
      return

    print "Git aliases containing '" & args[0] & "' ->"
    let rows = buildRows(pairs, longest)
    echo rows.columnize(gutter = 4)
  else:
    let cmd = args[1..args.high].join " "
    let (res, code) = createAlias(args[0], cmd)
    if code != 0:
      fail "Could not create alias '" & args[0] & "'" &
        "\n" & (if res != "": indent(res, 2) else: "")
    else:
      print "Created alias '" & args[0] & "' = " & cmd
