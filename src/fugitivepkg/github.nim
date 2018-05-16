import asyncdispatch
import httpclient
import json
import strutils
import tables
import times

from os import sleep

import common/[cli, config, humanize]

type
  GitHubUser* = object
    login*: string
    id*: int
    avatar_url*: string
    gravatar_id*: string
    url*: string
    html_url*: string
    followers_url*: string
    following_url*: string
    gists_url*: string
    starred_url*: string
    subscriptions_url*: string
    organizations_url*: string
    repos_url*: string
    events_url*: string
    received_events_url*: string
    `type`*: string
    site_admin*: bool
    name*: string
    company*: string
    blog*: string
    location*: string
    email*: string
    bio*: string
    public_repos*: int
    public_gists*: int
    followers*: int
    following*: int
    created_at*: string
    updated_at*: string

const
  baseUrl = "https://github.com/"
  timeFormat = "yyyy-MM-dd'T'HH-mm-sszzz"

proc getUserObject* (username: string): Future[GitHubUser] {.async.} =
  let client = newAsyncHttpClient()
  let res = await client.get "https://api.github.com/users/" & username
  let body = parseJson await res.body
  result = body.to(GitHubUser)

proc getRepoCount* (username: string): Future[int] {.async.} =
  result = (await username.getUserObject).publicRepos

proc getUserEmail* (username: string): Future[string] {.async.} =
  result = (await username.getUserObject).email

proc getUserAge* (username: string): Future[string] {.async.} =
  let user = await username.getUserObject
  let created = parse(user.createdAt, timeFormat)
  let diff = epochTime() - created.toTime.toUnix.float
  result = humanize diff

proc resolveRepoURL* (repo: string, failMsg = "this action"): string =
  case repo.count '/'
  of 0:
    let owner = getConfigValue("github", "username")
    if owner != "":
      result = baseUrl & owner & "/" & repo
    else:
      let res = promptResponse("Enter your GitHub username:")
      if res == "":
        failSoft "GitHub username required for " & failMsg & "\n"
        result = ""
      else:
        let username = setConfigValue("github", "username", res)
        result = baseUrl & username & "/" & repo
  of 1: result = baseUrl & repo
  else: result = repo
