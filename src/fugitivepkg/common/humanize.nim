from math import round
from strutils import join

const
  second = 1000u64
  minute = 60u64 * second
  hour = 60u64 * minute
  day = 24u64 * hour
  year = 365u64 * day
  unitValues = [year, day, hour, minute, second, 1]
  unitLabels = ["y", "d", "h", "m", "s", "ms"]

proc parseToUnits (duration: float): seq[string] =
  var remainder = (duration * 1000).round.uint64
  for i, unit in unitValues:
    let count = remainder div unit
    if count == 0: continue
    remainder -= count * unit
    result.add $count & unitLabels[i]

proc humanize* (duration: float): string =
  let times = duration.parseToUnits
  result = if times.len != 0: times.join(" ") else: "just now"
