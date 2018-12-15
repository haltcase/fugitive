import asyncdispatch, httpclient, json, options, strformat, strutils, sugar, tables
from os import getEnv, extractFilename

import gara, unpack

import common/[cli, configfile, util]

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

  GitHubReleaseError* = object of CatchableError

const
  baseUrl* = "https://github.com/"
  baseApi* = "https://api.github.com/"

proc getUserObject* (username: string): Future[Option[GitHubUser]] {.async.} =
  let client = newAsyncHttpClient()
  { body, code } <- await client.get(&"{baseApi}users/{username}")

  if code == Http404: return

  let raw = parseJson await body
  result = some raw.to(GitHubUser)

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

template raiseReleaseError (body: string, prefix = "Failed to create release: ") =
  raise newException(
    GitHubReleaseError,
    prefix & " " & (if body == "": body else: parseJson(body)["message"].getStr)
  )

proc getReleaseByName* (repo, tag: string; token = ""): Future[Option[GitHubRelease]] {.async.} =
  let resolvedUrl = repo.resolveRepoUrl(baseUrl = baseApi & "repos/")
  if resolvedUrl.isNone: return

  let client = newAsyncHttpClient()
  if token != "":
    client.headers = newHttpHeaders({ "Authorization": "token " & token })
  let url = &"{resolvedUrl.get}/releases/tags/{tag}"
  { body, code } <- await client.get(url)

  if code == Http404: return

  if not code.is2xx:
    raiseReleaseError("", "Failed to fetch release: " & await body)

  result = parseReleaseResponse(await body)

proc createRelease* (
  repo, tag, token: string;
  description = "", targetCommit = "master";
  draft = false, prerelease = false
): Future[Option[GitHubRelease]] {.async.} =
  let resolvedUrl = repo.resolveRepoUrl(baseUrl = baseApi & "repos/")
  if resolvedUrl.isNone: return

  result = await resolvedUrl.get.getReleaseByName(tag, token)
  if result.isSome: return

  let client = newAsyncHttpClient()
  client.headers = newHttpHeaders({ "Authorization": "token " & token })
  { body, code } <- await client.post(resolvedUrl.get & "/releases", body = $(%*{
    "name": tag,
    "tag_name": tag,
    "body": description,
    "target_commitish": if targetCommit == "": "master" else: targetCommit,
    "draft": draft,
    "prerelease": prerelease
  }))

  if not code.is2xx:
    raiseReleaseError(await body)

  result = parseReleaseResponse(await body)

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
      "",
      "Failed to upload release asset; release doesn't exist or couldn't be created."
    )

  let
    filename = filepath.extractFilename
    url = release.get.uploadUrl.replace("{?name,label}", "?name=" & filename)
    client = newAsyncHttpClient()

  client.headers = newReleaseHeaders(token, filename)
  { body, code } <- await client.post(url, body = $filepath.readFile)

  if not code.is2xx:
    raiseReleaseError(await body, "Failed to upload release asset: ")

  result = some parseJson(await body).to(GitHubAsset)
