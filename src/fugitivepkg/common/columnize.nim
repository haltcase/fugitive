import future
import math
import sequtils
import strutils
import terminal

proc columnize* (
  rows: seq[string],
  padding = 2,
  gutter = 2,
  indent = 2,
  columns = 3,
  fillChar = ' ',
  fillHeight = true,
  noTerminal = false,
  maxHeight = 12,
  maxWidth = 80
): string =
  let height = if noTerminal: maxHeight else: terminalHeight()
  let width = if noTerminal: maxWidth else: terminalWidth()

  if fillHeight and rows.len < height:
    return indent.spaces & rows.join("\n" & indent.spaces) & "\n"

  let cellWidth = rows.mapIt(it.len).max + padding
  let colCount = (width / cellWidth).floor.int.min(columns)
  var dist = rows.distribute colCount
  if dist.len == 1: return dist.join "\n"

  # ensure all columns have the same number of items
  if dist[^1].len < dist[0].len:
    dist[^1].add dist[^1][^1].len.spaces

  result = ""
  for i, val in dist[0]:
    var row = val
    for col in dist[1..^1]:
      row &= " " & repeat(fillChar, gutter) & " " & col[i]
    result &= indent.spaces & row & "\n"
