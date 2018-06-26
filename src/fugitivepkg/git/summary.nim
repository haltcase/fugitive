include ../base

import os
import ospaths
import sequtils
import strutils
import times

const
  cmdGetAge = """
  git rev-list HEAD --pretty="format: %ar" --max-parents=0
  """.strip
  cmdGetCreatedDate = """
  git rev-list HEAD --pretty="format: %ai" --max-parents=0
  """.strip
  cmdGetActiveDays = """
  git log --pretty="format: %ai"
  """.strip
  usageMessage = """
  Usage: fugitive summary

  Prints a summary of the current repository including some statistics,
  such as when it was created, how active it is, number of commits, etc.
  """

proc getRepoAge (created = false): string =
  let (res, code) =
    if created: execCmdEx cmdGetCreatedDate
    else: execCmdEx cmdGetAge

  if code != 0: return "never"
  let lines = res.splitLines
  result =
    if lines.len > 1: lines[1].strip
    else: lines[0].strip

proc extractDate (str: string): string =
  str.strip.split[0]

proc getActiveDays (): string =
  let (res, code) = execCmdEx cmdGetActiveDays
  if code != 0: return "0 days"
  if res.endsWith("does not have any commits yet\n"):
    return "0 days"

  let created = getRepoAge(true).extractDate
  let parsed = created.parse "yyyy-MM-dd"
  let diff = epochTime() - parsed.toTime.toUnix.float
  let totalDays = diff / 86400

  let activeDays =
    res
    .splitLines
    .filterIt(it.strip != "")
    .map(extractDate)
    .deduplicate
    .len

  let percentActive = activeDays / totalDays.int
  let percentString = percentActive.formatFloat(precision = 2)
  result = $activeDays & " days (" & percentString & "%)"

proc getCommitCount (): string =
  let (res, code) = execCmdEx "git rev-list HEAD --count"
  if code != 0: return "0"
  result = strip res

proc getFileCount (): int =
  let (res, code) = execCmdEx "git ls-files"
  if code != 0: return 0
  result = countLines res

proc summary* (args: Arguments, opts: Options) =
  if "help" in opts:
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo(): fail errNotRepo

  print "Project summary ->"
  echo "  project   : " & getRepoName()
  echo "  created   : " & getRepoAge()
  echo "  active    : " & getActiveDays()
  echo "  commits   : " & getCommitCount()
  echo "  files     : " & $getFileCount()
  echo ""
