import math
import sequtils
import strutils

const
  SECOND = 1000
  MINUTE = 60 * SECOND
  HOUR = 60 * MINUTE
  DAY = 24 * HOUR
  YEAR = 365 * DAY
  UNITS = [YEAR, DAY, HOUR, MINUTE, SECOND, 1]
  LABELS = ["y", "d", "h", "m", "s", "ms"]

proc parseToUnits [T] (duration: T): seq[string] =
  result = @[]
  let rounded = duration.float64.round.int
  var remainder = rounded * 1000
  for i, unit in UNITS:
    let count = remainder div unit
    if count == 0: continue
    remainder -= count * unit
    result.add $count & LABELS[i]

proc humanize* [T] (duration: T): string =
  let times = parseToUnits duration
  result = if times.len != 0: times.join " " else: "0ms"
