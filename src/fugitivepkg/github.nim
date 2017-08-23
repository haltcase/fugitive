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
  BASE_URL = "https://github.com/"
  TIME_FORMAT = "yyyy-MM-dd'T'HH-mm-sszzz"

proc getUserObject* (username: string): Future[GitHubUser] {.async.} =
  let client = newAsyncHttpClient()
  let res = await client.get "https://api.github.com/users/" & username
  let body = parseJson await res.body
  result = to(body, GitHubUser)

proc getRepoCount* (username: string): Future[int] {.async.} =
  result = (await getUserObject username).publicRepos

proc getUserEmail* (username: string): Future[string] {.async.} =
  result = (await getUserObject username).email

proc getUserAge* (username: string): Future[string] {.async.} =
  let user = await getUserObject username
  let created = parse(user.createdAt, TIME_FORMAT)
  let diff = getTime() - created.toTime
  result = humanize diff

proc resolveRepoURL* (repo: string, failMsg = "this action"): string =
  case repo.count '/':
  of 0:
    let owner = getConfigValue("github", "username")
    if owner != "":
      result = BASE_URL & owner & "/" & repo
    else:
      let res = promptResponse("Enter your GitHub username:").strip
      if res == "":
        failSoft "GitHub username required for " & failMsg & "\n"
        result = ""
      else:
        let username = setConfigValue("github", "username", res)
        result = BASE_URL & username & "/" & repo
  of 1: result = BASE_URL & repo
  else: result = repo
