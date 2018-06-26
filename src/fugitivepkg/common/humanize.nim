from math import round
from strutils import join

const
  second = 1000
  minute = 60 * second
  hour = 60 * minute
  day = 24 * hour
  year = 365 * day
  unitValues = [year, day, hour, minute, second, 1]
  unitLabels = ["y", "d", "h", "m", "s", "ms"]

proc parseToUnits (duration: int | float): seq[string] =
  result = @[]
  var remainder = (duration.float * 1000).round.int
  for i, unit in unitValues:
    let count = remainder div unit
    if count == 0: continue
    remainder -= count * unit
    result.add $count & unitLabels[i]

proc humanize* (duration: int | float): string =
  let times = duration.parseToUnits
  result = if times.len != 0: times.join(" ") else: "just now"
