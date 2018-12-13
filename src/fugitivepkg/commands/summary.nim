include ../base

import os, sequtils, times
import gara

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

  let
    created = getRepoAge(true).extractDate
    parsed = created.parse "yyyy-MM-dd"
    diff = epochTime() - parsed.toTime.toUnix.float
    totalDays = diff / 86400

  let activeDays =
    res
    .splitLines
    .filterIt(it.strip != "")
    .map(extractDate)
    .deduplicate
    .len

  let percentActive = activeDays / totalDays.int
  let percentString = percentActive.formatFloat(precision = 2)
  result = &"{activeDays} days ({percentString}%)"

proc getCommitCount (): string =
  result = match execCmdEx "git rev-list HEAD --count":
    (@res, 0): strip res
    _: "0"

proc getFileCount (): int =
  result = match execCmdEx "git ls-files":
    (@res, 0): countLines res
    _: 0

proc summary* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo(): fail errNotRepo

  print strip(&"""
  Project summary ->

  project   : {getRepoName()}
  created   : {getRepoAge()}
  active    : {getActiveDays()}
  commits   : {getCommitCount()}
  files     : {getFileCount()}
  """)