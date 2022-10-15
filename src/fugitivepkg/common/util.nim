import options, strformat, strutils
from os import getCurrentDir, dirExists, splitFile
from osproc import execCmdEx
from parseutils import parseUntil

import unpack

import ../types

template `&&`* (left: CommandResult, right: CommandResult): CommandResult =
  let tmp = left
  if tmp.exitCode == 0: right else: tmp

proc removePrefix* (str, prefix: string): string =
  if str.startsWith(prefix): str[prefix.len..str.high]
  else: str

proc removeSuffix* (str, suffix: string): string =
  if str.endsWith(suffix): str[0..str.high - suffix.len]
  else: str

proc isGitRepo* (): bool =
  if not dirExists ".git": return false
  [res] <- execCmdEx "git rev-parse --git-dir"
  result = not res.startsWith "fatal: Not a git repository"

proc normalizeGitUrl* (url: string): string =
  # https://x-access-token:ghs_f39j@github.com/user/repo.git
  # https://github.com/user/repo.git
  # git@github.com:user/repo.git

  result.removeSuffix(".git")

  if url.startsWith("git@"):
    [_, base, user] <- url.split({'@', ':'})
    result = &"https://{base}/{user}"
  elif url.contains("x-access-token"):
    var token: string
    let charCount = url.parseUntil(token, '@')
    result = &"https://{url.substr(charCount + 1)}"
  else:
    result = url

proc getRepoUrl* (): string =
  [res, code] <- execCmdEx "git ls-remote --get-url origin"
  if code != 0 or res == "": return ""

  result = res.strip.normalizeGitUrl

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
