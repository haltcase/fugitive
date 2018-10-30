# fugitive &middot; [![nimble](https://flat.badgen.net/badge/available%20on/nimble/yellow)](https://nimble.directory/pkg/fugitive) ![license](https://flat.badgen.net/github/license/citycide/fugitive)

> Simple command line tool to make git more intuitive, along with useful GitHub addons.

fugitive provides new or alternative commands to use with git, and also
adds a few helpful tools for GitHub repositories.

It's similar to [`git-extras`][gitextras] but is designed to be more
portable. `git-extras` is written entirely as a set of shell scripts,
which means platform support outside Unix is at best hit or miss.

On the other hand, fugitive is written in [Nim][nim] to allow for better
portability. Other benefits are that Nim is super fast, flexible, and more
readable than the often cryptic bash syntax.

[Git Town][gittown] is a project with similar goals written in Go.

## installation

Linux x64 and Windows x64 prebuilt binaries are available from
[releases](https://github.com/citycide/fugitive/releases). Download the release
for your system and extract the binary within to somewhere in your `$PATH`.

> macOS builds aren't ready yet but are a future goal

If you have [Nim][nim] and [Nimble][nimble] installed
( and `~/.nimble/bin` is in your path ), you can also simply run:

```shell
nimble install fugitive
```

This will make `fugitive` available to you anywhere.

## usage

```shell
Usage: fugitive [command] [...args] (...options)

Commands:
  age       <username>           Display the age of the profile for <username>
  alias     [name [--remove|-r]] [expansion]
                                 List, add, or remove git aliases
  config    [key] [value] [--remove|-r]
                                 Set, update, or remove fugitive settings
  changelog [file] [--tag|-t:<tag>] [--overwrite|-o] [--no-anchor] [--init]
                                 Write changes since last tag to file or stdout
  clone     <...repos>           Alias for `fugitive mirror`
  install   [--override|-o] [--force|-y]
                                 Alias various fugitive commands as git subcommands
  lock      <...files>           Prevent changes to the specified files from being tracked
  mirror    <...repos>           Wrapper around `git clone` with various URL shorthands
  open      [repo]               Open the current or specified repository's homepage
  release   <tag> [--repo|-r:<repo>] [--file|-f:<filepath>] [--description|-d:<desc>]
            [--draft|-D] [--prerelease|-p] [--targetCommit|-T:<commitish>]
                                 Create a GitHub release and/or upload assets to a release
  repos     <username>           Display the number of public repos for <username>
  scrap     <...files>  [--all|-a]
                                 Discard local changes to the specified files
  summary                        Summarize git repository statistics
  undo      [#] [--hard|-h]      Undo the last commit ( or last # commits )
  uninstall                      Remove git aliases added by `install`
  unlock    <...files>           Resume tracking changes to these locked files
  unstage   <...files> [--all|-a]
                                 Remove files from the git stage area

Options:
  --help, -h       Show this help message
  --version, -v    Output the fugitive version number
```

For help on a specific command, provide the `--help`/`-h` flag _after_
that command, ie. `fugitive changelog -h`.

## configuration

fugitive stores a configuration file in your user configuration directory
called `fugitive.ini`. You can manage this file using the `fugitive config`
command.

> TIP: Using the `fugitive config` command with no arguments will print the full
filepath to your config file.

You can, for example, tell fugitive explicitly what to use as your GitHub
username when using various shorthand features:

```shell
fugitive config github.username <name>
```

Here's the full list of available settings:

| setting name               | type            | default value                |
| -------------------------- | --------------- | ---------------------------- |
| terminal_colors            | `bool`          | on                           |
| github.username            | `string`        | -                            |

> Settings of the type `bool` are retrieved using Nim's [`parseBool`][nimparsebool],
so they can be set to any of `y`, `yes`, `true`, `1`, `on` or `n`, `no`, `false`, `0`, `off`.

### username

Some commands support a shorthand for referring to GitHub repositories,
provided you've configured your GitHub username or it can be inferred
from your git config.

#### `<name>`

The simplest shorthand is for referencing one of your own repositories,
which you can do by simply entering its name. For example if you're
**[@citycide][citycide]**, entering `fugitive open cascade` would open
your browser to **[`cascade`][cascade]**.

#### `<owner>/<name>`

You can also use any `<owner>/<project>` combination you'd like, such as:

* `fugitive open nim-lang/nim`
* `fugitive mirror soasme/nim-markdown`

By default fugitive will use your local git username (from
`git config --global user.name`) for these shorthands but you can explicitly
set it yourself. You'll also be prompted to provide it if you try to use
these shorthands and fugitive isn't able to infer it.

## alias installation

After installation, you can make some of fugitive's commands more accessible by
running `fugitive install`, which will attach them to git as subcommands,
making `git undo == fugitive undo`.

Commands installed to git include:

```
alias
changelog
lock
mirror
open
release
scrap
summary
undo
unlock
unstage
```

Existing aliases are safe as fugitive will not override them unless
the `--override` ( or `-o` ) flag is explicitly passed.

If you want to remove these installed aliases, use `fugitive uninstall`.
Only aliases that fugitive installed and match the fugitive command will
be removed.

> Note the `mirror` command - git commands can't be overridden, so while
`fugitive clone` is possible it can't be aliased as a git subcommand.
Therefore `fugitive mirror` is the main command and the one that will
be attached to git, while `clone` is just an alias for convenience.

## building

To build fugitive from source you'll need to install [Nim][nim] and its package
manager [Nimble][nimble].

> Currently, building should work on most platforms. Cross-compilation
(building for other platforms than the current one) is only tested on
a unix system.

1. Clone the repo: `git clone https://github.com/citycide/fugitive.git`
2. Move into the newly cloned directory: `cd fugitive`
3. Install dependencies: `nimble install`
4. Compile for your platform: `nimble build` (development)
5. Compile for other platforms: run `nimble tasks` for available commands
6. Compile all release versions: `nimble build_releases`
   - this will generate and package prebuilt binaries for all supported
     cross-compile targets

## contributing

This project is open to contributions of all kinds! Please check and search
the [issues](https://github.com/citycide/fugitive/issues) if you encounter a
problem before opening a new one. Pull requests for improvements are also
welcome &mdash; see the steps above for [development](#building).

## license

MIT © [Bo Lingen / citycide](https://github.com/citycide)

[gitextras]: https://github.com/tj/git-extras
[gittown]: https://github.com/Originate/git-town
[nim]: https://nim-lang.org
[nimble]: https://github.com/nim-lang/nimble
[citycide]: https://github.com/citycide
[cascade]: https://github.com/citycide/cascade
[nimparsebool]: https://nim-lang.org/docs/strutils.html#parseBool%2Cstring
