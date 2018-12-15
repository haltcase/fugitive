include ../base

from os import existsDir

from ../github import resolveRepoURL

const
  usageMessage = """
  Usage: fugitive mirror <...repos> [--directory|-d:<...dirs>]

  Wrapper around `git clone` allowing for useful GitHub shorhands.
  Any number of repositories can be passed and can be in the
  following forms:

    fugitive mirror <name>           # your GitHub repository
    fugitive mirror <owner>/<name>   # GitHub repository
    fugitive mirror <url>            # any git repository URL

  If using the <name> shorthand, a GitHub username is required. You may
  be prompted for one if it hasn't been configured or if it can't be
  pulled from your local git config.

  The optional `--directory` (-d) flag allows specifying the directory
  into which the repository should be cloned. In the case of multiple
  repositories, multiple directories can be provided in a comma
  separated list (elements can be skipped).

  Examples:

    fugitive mirror citycide/glob citycide/cascade citycide/fugitive -d:glob,,fugitive
  """

proc mirror* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool) or args.len < 1:
    echo "\n" & usageMessage
    quit 0

  let dirs = getOptionValue(opts, "d", "directory", string).split ','

  var good = 0
  for i, arg in args:
    let url = resolveRepoUrl(arg, "`clone` repo shorthand")
    if url.isNone: continue

    let target =
      if dirs.len >= i + 1 and dirs[i].len > 0: dirs[i]
      else: url.get.split('/')[^1]

    if target.existsDir: continue

    [res, code] <- execCmdEx(&"git clone {url.get} {target}")
    if code != 0:
      fail &"Failed to clone into '{target}'\n{res.strip.indent(2)}"
    else:
      inc good

  print &"Clone complete ({good} of {args.len})"
