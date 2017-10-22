include ../base

import os
import ospaths
import sequtils

const
  cmdGetAge = """
  git rev-list HEAD --pretty="format: %ar" --max-parents=0
  """
  cmdGetCreatedDate = """
  git rev-list HEAD --pretty="format: %ai" --max-parents=0
  """
  cmdGetActiveDays = """
  git log --pretty="format: %ai"
  """


proc getActiveDays (): int =
  let (res, code) = execCmdEx GET_DAYS
  if code != 0: return 0
  if res.endsWith("does not have any commits yet\n"):
    return 0

  result = res.splitLines.deduplicate.len

proc getCommitCount (): string =
  let (res, code) = execCmdEx "git rev-list HEAD --count"
  if code != 0: return "0"
  result = strip res

proc getFileCount (): int =
  let (res, code) = execCmdEx "git ls-files"
  if code != 0: return 0
  result = countLines res

proc getRepoAge (): string =
  let (res, code) = execCmdEx GET_AGE
  if code != 0: return "never"
  let lines = splitLines res
  result = if lines.len > 1: lines[1] else: lines[0]

proc summary* (args: Arguments, opts: Options) =
  if not isGitRepo(): fail errNotRepo

  print "Project summary ->"
  echo "  project   : " & getRepoName()
  echo "  created   : " & $getRepoAge()
  echo "  active    : " & $getActiveDays() & " days"
  echo "  commits   : " & getCommitCount()
  echo "  files     : " & $getFileCount()
  echo ""
