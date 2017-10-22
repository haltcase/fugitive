import math
import sequtils
import strutils

const
  second = 1000
  minute = 60 * second
  hour = 60 * minute
  day = 24 * hour
  year = 365 * day
  unitValues = [year, day, hour, minute, second, 1]
  unitLabels = ["y", "d", "h", "m", "s", "ms"]

proc parseToUnits [T] (duration: T): seq[string] =
  result = @[]
  let rounded = duration.float64.round.int
  var remainder = rounded * 1000
  for i, unit in unitValues:
    let count = remainder div unit
    if count == 0: continue
    remainder -= count * unit
    result.add $count & unitLabels[i]

proc humanize* [T] (duration: T): string =
  let times = parseToUnits duration
  result = if times.len != 0: times.join " " else: "0ms"
