include ../base

proc unstage* (args: Arguments, opts: Options) =
  if not isGitRepo(): fail NOT_REPO
  discard argCheck(args, 1, "File names required.")

  let (res, code) = execCmdEx "git reset HEAD " & args.join(" ")

  if code == 0:
    print "Files unstaged"
    quit 0

  if res.startsWith "fatal: ambiguous argument 'HEAD'":
    # we're probably in a new repo with no commits
    # so thanks to git's highly unpredictable interface, we need
    # to use a totally different command to remove staged files
    # but unlike `git add`, `git rm` only accepts a single file
    # at a time, so we'll have to run a separate command for each one
    var good = 0
    for _, arg in args:
      let (res, code) = execCmdEx "git rm --cached " & arg
      if code != 0:
        failSoft "Could not unstage '" & arg & "'\n" & res.indent 2
      else:
        good += 1

    print "Files unstaged (" & $good & " of " & $args.len & ")"
  else:
    fail res
