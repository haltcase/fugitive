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

  <name> shorthand requires your GitHub username to be configured
  with fugitive and will prompt if it hasn't been set yet.
  """

proc open* (args: Arguments, opts: Options) =
  if args.len < 1:
    if isGitRepo():
      let (res, code) = execCmdEx "git remote -v"
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

  when defined linux:
    let (res, _) = execCmdEx "echo $DISPLAY"
    if res.strip == "":
      fail "No display detected - cannot open repository"

  let url = resolveRepoURL(args[0], "`open` repo shorthand")
  openDefaultBrowser(url)
