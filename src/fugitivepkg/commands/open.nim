include ../base

import browsers

from ../github import resolveRepoURL

const
  usageMessage = """
  Usage: fugitive open <repo>

  Open the specified repository in your browser. Allows for
  fully specified repo URLs as well as shorthand <owner>/<name>
  and <name> GitHub identifiers.

    fugitive open <name>            # your GitHub repository
    fugitive open <owner>/<name>    # GitHub repository
    fugitive open <url>             # any git repository URL

  If using the <name> shorthand, a GitHub username is required. You may
  be prompted for one if it hasn't been configured or if it can't be
  pulled from your local git config.
  """

proc open* (args: Arguments, opts: Options) =
  if opts.get("h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if args.len < 1:
    if isGitRepo():
      [res, code] <- execCmdEx "git remote -v"
      if code == 0 and res != "":
        res
        .splitLines[0]
        .split[1]
        .removeSuffix(".git")
        .openDefaultBrowser
        quit 0
    else:
      echo "\n" & usageMessage
      quit 0

  let url = resolveRepoUrl(args[0], "`open` repo shorthand")
  if url.isNone: return

  when not defined linux:
    openDefaultBrowser(url.get)
  else:
    if "Microsoft" in readFile("/proc/sys/kernel/osrelease"):
      [res, code] <- execCmdEx "cmd.exe /c start \"\" " & url.get
      if code != 0: fail res
      return

    [res] <- execCmdEx "echo $DISPLAY"
    if res.strip == "":
      fail "No display detected - cannot open repository"
