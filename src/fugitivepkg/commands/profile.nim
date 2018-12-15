include ../base

import asyncdispatch, sugar, times

import ../github
import ../common/humanize

const
  timeFormat = initTimeFormat "yyyy-MM-dd'T'HH:mm:sszzz"
  usageMessage = """
  Usage: fugitive profile [name]

  Print a summary of the given GitHub user including profile age,
  activity, and repositories. If no username is provided, it will
  be inferred from the current user.

  Examples:

    # view your own profile
    fugitive profile

    # view someone else's profile
    fugitive profile citycide
  """

proc repoCount* (user: GitHubUser): int =
  user.publicRepos

proc profileAge* (user: GitHubUser): string =
  let created = user.createdAt.parse(timeFormat)
  let diff = epochTime() - created.toTime.toUnix.float
  result = humanize diff

proc profile* (args: Arguments, opts: Options) =
  if getOptionValue(opts, "h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  let userOption = (if args.len == 0: getGitUsername() else: some args[0])
    .flatMap do (name: string) -> Option[GitHubUser]: waitFor name.getUserObject

  match userOption:
    Some(@user):
      print "Profile summary ->\p\p" & strip(&"""
      {user.login} ({user.name})
      created {user.profileAge} ago
      {user.repoCount} public repositories
      """).unindent.indent(2)
    _:
      fail "Username must be provided"