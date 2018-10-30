import asyncdispatch, httpclient, json, options, strformat, strutils, sugar, tables, times
from os import getEnv, extractFilename

import common/[cli, configfile, humanize, util]

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

  GitHubRelease* = object
    id*: int
    body*, tag_name*: string
    upload_url*, html_url*: string
    created_at*, published_at*: string

  GitHubAsset* = object
    id*, size*: int
    name*, label*, state*, content_type*: string
    url*, browser_download_url*: string
    created_at*, updated_at*: string

  GitHubReleaseError* = object of Exception

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

template parseReleaseResponse (body: string): Option[GitHubRelease] =
  some body.parseJson.to(GitHubRelease)

template raiseReleaseError (body: string) =
  raise newException(
    GitHubReleaseError,
    "Failed to create release: " & parseJson(body)["message"].getStr
  )

proc getReleaseByName* (repo, tag: string): Future[Option[GitHubRelease]] {.async.} =
  let resolvedUrl = repo.resolveRepoUrl(baseUrl = baseApi & "repos/")
  if resolvedUrl.isNone: return

  let client = newAsyncHttpClient()
  let url = &"{resolvedUrl.get}/releases/tags/{tag}"
  let res = await client.get(url)

  if not res.code.is2xx:
    raiseReleaseError("Failed to fetch release: " & await res.body)

  result = parseReleaseResponse(await res.body)

proc createRelease* (
  repo, tag, token: string;
  description = "", targetCommit = "master";
  draft = false, prerelease = false
): Future[Option[GitHubRelease]] {.async.} =
  let resolvedUrl = repo.resolveRepoUrl(baseUrl = baseApi & "repos/")
  if resolvedUrl.isNone: return

  result = await resolvedUrl.get.getReleaseByName(tag)
  if result.isSome: return

  let client = newAsyncHttpClient()
  client.headers = newHttpHeaders({ "Authorization": "token " & token })
  let res = await client.post(resolvedUrl.get & "/releases", body = $(%*{
    "name": tag,
    "tag_name": tag,
    "body": description,
    "target_commitish": if targetCommit == "": "master" else: targetCommit,
    "draft": draft,
    "prerelease": prerelease
  }))

  if not res.code.is2xx:
    raiseReleaseError(await res.body)

template newReleaseHeaders (token, filename: string): HttpHeaders =
  newHttpHeaders({
    "Authorization": "token " & token,
    "Content-Type": "application/zip",
    "name": filename,
    "label": filename
  })

proc uploadReleaseFile* (
  repo, tag, token, filepath: string;
  description, targetCommit = "";
  draft, prerelease = false
): Future[Option[GitHubAsset]] {.async.} =
  let release = await createRelease(
    repo, tag, token, description, targetCommit, draft, prerelease
  )

  if release.isNone:
    raiseReleaseError(
      "Failed to upload release asset; release doesn't exist or couldn't be created."
    )

  let
    filename = filepath.extractFilename
    url = release.get.uploadUrl.replace("{?name,label}", "?name=" & filename)
    client = newAsyncHttpClient()

  client.headers = newReleaseHeaders(token, filename)
  let res = await client.post(url, body = $filepath.readFile)

  if not res.code.is2xx:
    raiseReleaseError("Failed to upload release asset: " & await res.body)

  result = some parseJson(await res.body).to(GitHubAsset)
