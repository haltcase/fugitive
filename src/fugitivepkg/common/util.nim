from os import getCurrentDir, existsDir, splitFile
from osproc import execCmdEx
import strutils

proc removeSuffix* (str, suffix: string): string =
  if str.endsWith(suffix): str[0..str.high - suffix.len]
  else: str

proc isGitRepo* (): bool =
  if not existsDir ".git": return false
  let (res, _) = execCmdEx "git rev-parse --git-dir"
  result = not res.startsWith "fatal: Not a git repository"

proc normalizeGitUrl* (url: string): string =
  if url.startsWith("git@"):
    let parts = url.split({'@', ':'})
    return "https://" & parts[1] & "/" & parts[2]
  else:
    return url

proc getRepoUrl* (): string =
  let (res, code) = execCmdEx "git ls-remote --get-url origin"
  if code != 0 or res == "": return ""

  result = res.strip.removeSuffix(".git").normalizeGitUrl

proc getRepoName* (): string =
  let (res, code) = execCmdEx "git ls-remote --get-url origin"

  if code == 0 and res != "":
    let line = res.strip
    let start = line.rfind("/")
    let finish = line.find(".git")
    result = line[start + 1..finish - 1]
  else:
    let (_, name, _) = splitFile getCurrentDir()
    result = name
