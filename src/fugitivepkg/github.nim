import asyncdispatch, httpclient, json, options, strformat, strutils, sugar, tables, times
from os import getEnv, extractFilename

import common/[cli, config, humanize, util]

type
  GitHubUser* = object
    id*: int
    `type`*, url*: string
    gravatar_id*, login*, avatar_url*: string
    html_url*, followers_url*, following_url*, gists_url*, starred_url*: string
    subscriptions_url*, organizations_url*, repos_url*: string
    events_url*, received_events_url*: string
    name*, company*, blog*, location*, email*, bio*: string
    public_repos*, public_gists*, followers*, following*: int
    created_at*, updated_at*: string
    site_admin*: bool

const
  baseUrl = "https://github.com/"
  baseApi = "https://api.github.com/"
  timeFormat = initTimeFormat "yyyy-MM-dd'T'HH:mm:sszzz"

proc getUserObject* (username: string): Future[Option[GitHubUser]] {.async.} =
  let client = newAsyncHttpClient()
  let res = await client.get(&"{baseApi}users/{username}")

  if res.code == Http404:
    return

  let body = parseJson await res.body
  result = some body.to(GitHubUser)

proc getRepoCount* (username: string): Future[Option[int]] {.async.} =
  result = (await username.getUserObject)
    .map(user => user.publicRepos)

proc getUserAge* (username: string): Future[Option[string]] {.async.} =
  result = (await username.getUserObject)
    .map(user => user.createdAt.parse(timeFormat))
    .map(created => epochTime() - created.toTime.toUnix.float)
    .map(diff => humanize diff)

proc resolveRepoUrl* (repo: string, failMsg = "this action", baseUrl = baseUrl): Option[string] =
  case repo.count '/'
  of 0:
    let username = getConfigValue("github", "username")
    let owner = if username == "": getGitUsername() else: some username

    if owner.isSome:
      result = owner.map(v => baseUrl & v & "/" & repo)
    else:
      let res = promptResponse("Enter your GitHub username:")
      if res == "":
        failSoft &"GitHub username required for {failMsg}\n"
        return
      else:
        let username = setConfigValue("github", "username", res)
        result = some baseUrl & username & "/" & repo
  of 1: result = some baseUrl & repo
  else: result = some repo
