import options, strformat, strutils
from os import getCurrentDir, existsDir, splitFile
from osproc import execCmdEx

import unpack

proc removeSuffix* (str, suffix: string): string =
  if str.endsWith(suffix): str[0..str.high - suffix.len]
  else: str

proc isGitRepo* (): bool =
  if not existsDir ".git": return false
  [res] <- execCmdEx "git rev-parse --git-dir"
  result = not res.startsWith "fatal: Not a git repository"

proc normalizeGitUrl* (url: string): string =
  if url.startsWith("git@"):
    [_, base, user] <- url.split({'@', ':'})
    result = &"https://{base}/{user}"
  else:
    result = url

proc getRepoUrl* (): string =
  [res, code] <- execCmdEx "git ls-remote --get-url origin"
  if code != 0 or res == "": return ""

  result = res.strip.removeSuffix(".git").normalizeGitUrl

proc getRepoName* (): string =
  [res, code] <- execCmdEx "git ls-remote --get-url origin"

  if code == 0 and res != "":
    let line = res.strip
    let start = line.rfind("/")
    let finish = line.find(".git")
    result = line[start + 1..finish - 1]
  else:
    result = getCurrentDir().splitFile.name

proc getGitUsername* (): Option[string] =
  [res, code] <- execCmdEx "git config --global user.name"
  if code != 0 or res == "": return
  result = some res.strip
