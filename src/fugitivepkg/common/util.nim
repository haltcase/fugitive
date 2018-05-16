import os
import osproc
import strutils

proc removeSuffix* (str, suffix: string): string =
  if str.endsWith(suffix): str[0..str.high - suffix.len]
  else: str

proc isGitRepo* (): bool =
  if not existsDir ".git": return false
  let (res, _) = execCmdEx "git rev-parse --git-dir"
  result = not res.startsWith "fatal: Not a git repository"

proc getRepoName* (): string =
  let (res, code) = execCmdEx "git remote -v"

  if code == 0 and res != "":
    let lines = res.splitLines
    let start = lines[0].rfind("/")
    let finish = lines[0].find(".git")
    result = lines[0][start + 1..finish - 1]
  else:
    let (_, name, _) = splitFile getCurrentDir()
    result = name
