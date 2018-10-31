include ../base

import asyncDispatch, options, os

import ../github

const
  usageMessage = """
  Usage: fugitive release <tag> [--repo|-r:<repo>]
    [--file|-f:<filepath>] [--description|-d:<desc>]
    [--desc-file|-D:<filepath>] [--draft|-N] [--prerelease|-p]
    [--target-commit|-T:<commitish>]

  Create a GitHub release and/or upload assets to a release.
  A GitHub token with the appropriate scope (usually `public_repo`)
  is required and must be in the `GITHUB_TOKEN` environment
  variable.

  Assets can be uploaded without creating the release first since
  the release will be created if it doesn't exist.

  The `--repo` (-r) argument can be omitted if the current directory
  is a git repo and the project URL can be inferred. If provided, it
  follows fugitive's standard repo resolution logic:

    --repo:<name>           # your GitHub repository
    --repo:<owner>/<name>   # GitHub repository
    --repo:<url>            # any git repository URL

  Since `description` will likely contain special characters such as
  double quotes or backticks, either use `--desc-file` (-D) instead or
  make sure to escape it yourself which is shell-specific. These might work:

    # powershell
    -d:"$((get-content changelog.md) -replace '"', '\\\"')"

    # bash
    -d:"$(sed 's/[`"]/\\\0/g' changelog.md)"

  Examples:

    fugitive release v1.2.1                                 # create release
    fugitive release v1.2.2 --file:myapp_win_x64.zip        # upload asset to release
    fugitive release v1.2.3 -f:app.zip -r:citycide/fugitive # specify GitHub repo
  """

proc getRepo (opts: Options, repo: var Option[string]): bool =
  repo = getOptionValue(opts, "r", "repo")
    .resolveRepoUrl("`release` shorthand", baseApi & "repos/")
  result = repo.isSome

proc release* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  var repo: Option[string]
  if not getRepo(opts, repo):
    repo = getRepoUrl().resolveRepoUrl("`release` command")
    if repo.isNone: fail errNotRepo

  argCheck(args, 1, "Tag name must be provided - use `--tag:<tag>`.")

  let file = getOptionValue(opts, "f", "file")
  let token = getEnv("GITHUB_TOKEN")

  if token == "":
    fail "A GitHub token is required to modify releases."

  let descFile = getOptionValue(opts, "D", "desc-file")
  let description =
    if descFile != "": descFile.readFile
    else: getOptionValue(opts, "d", "description")

  if file == "":
    try:
      let releaseOption = waitFor createRelease(
        repo.get,
        args[0],
        token,
        description,
        getOptionValue(opts, "T", "target-commit"),
        getOptionValue(opts, "N", "draft", bool),
        getOptionValue(opts, "p", "prerelease", bool)
      )

      if releaseOption.isSome:
        print "Release created at: " & releaseOption.get.htmlUrl
      else:
        # TODO: make sure this can't happen?
        fail "Couldn't create release for an unknown reason."
    except GitHubReleaseError as e:
      fail e.msg
  else:
    try:
      let uploadedFile = waitFor uploadReleaseFile(
        repo.get,
        args[0],
        token,
        file,
        description,
        getOptionValue(opts, "T", "target-commit"),
        getOptionValue(opts, "N", "draft", bool),
        getOptionValue(opts, "p", "prerelease", bool)
      )

      if uploadedFile.isSome:
        print "Release created at: " & uploadedFile.get.browserDownloadUrl
      else:
        # TODO: make sure this can't happen?
        fail "Couldn't upload file for an unknown reason."
    except GitHubReleaseError as e:
      fail e.msg
