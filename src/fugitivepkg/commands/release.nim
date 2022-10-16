include ../base

import asyncDispatch, os

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
    fugitive release v1.2.3 -f:app.zip -r:haltcase/fugitive # specify GitHub repo
  """

proc getRepo (opts: Options, repo: var Option[string]): bool =
  repo = opts.get("r", "repo")
    .resolveRepoUrl("`release` shorthand", baseApi & "repos/")
  result = repo.isSome

proc release* (args: Arguments, opts: Options) =
  if opts.get("h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  var repo: Option[string]
  if not getRepo(opts, repo):
    repo = getRepoUrl().resolveRepoUrl("`release` command")
    if repo.isNone: fail errNotRepo

  args.require(1, "Tag name must be provided - use `--tag:<tag>`.")

  let file = opts.get("f", "file")
  let token = getEnv("GITHUB_TOKEN")

  if token == "":
    fail "A GitHub token is required to modify releases."

  let descFile = opts.get("D", "desc-file")
  let description =
    if descFile != "": descFile.readFile
    else: opts.get("d", "description")

  if file == "":
    var releaseOption: Option[GitHubRelease]
    try:
      releaseOption = waitFor createRelease(
        repo.get,
        args[0],
        token,
        description,
        opts.get("T", "target-commit"),
        opts.get("N", "draft", bool),
        opts.get("p", "prerelease", bool)
      )
    except GitHubReleaseError as e:
      fail e.msg

    match releaseOption:
      Some(@release): print "Release created at: " & release.htmlUrl
      # TODO: make sure this can't happen?
      _: fail "Couldn't create release for an unknown reason."
  else:
    var uploadedFile: Option[GitHubAsset]
    try:
      uploadedFile = waitFor uploadReleaseFile(
        repo.get,
        args[0],
        token,
        file,
        description,
        opts.get("T", "target-commit"),
        opts.get("N", "draft", bool),
        opts.get("p", "prerelease", bool)
      )
    except GitHubReleaseError as e:
      fail e.msg

    match uploadedFile:
      Some(@file): print "Release created at: " & file.browserDownloadUrl
      # TODO: make sure this can't happen?
      _: fail "Couldn't upload file for an unknown reason."
