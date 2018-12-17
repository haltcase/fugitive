<a name="v0.10.0"></a>
### [`v0.10.0`](https://github.com/citycide/fugitive/compare/v0.9.0...v0.10.0) (2018-12-17)


###### BREAKING CHANGES

* the `age` and `repos` commands have been removed in favor of `profile`.

###### FEATURES

* add `pr` command for cloning pull requests ([`5bd116d`](https://github.com/citycide/fugitive/commit/5bd116dffb919fe153a2699e7f99541aba5f89cb))
* add `profile` command, remove `age` & `repos` ([`612a216`](https://github.com/citycide/fugitive/commit/612a2162b5fe2ff1c03788b3f17d939702e0be43))

---

<a name="v0.9.0"></a>
### [`v0.9.0`](https://github.com/citycide/fugitive/compare/v0.8.0...v0.9.0) (2018-10-31)


###### FEATURES

* **changelog:** support creating changelog between 2 tags ([`a40aaf3`](https://github.com/citycide/fugitive/commit/a40aaf3204a8a6227dffd6da9fef1d8ec433f799))

###### BUG FIXES

* **github:** use token more to avoid some API rate limits ([`ca44459`](https://github.com/citycide/fugitive/commit/ca444593bf54a954a2da444699eb35e63354f3f1))

---

<a name="v0.8.0"></a>
### [`v0.8.0`](https://github.com/citycide/fugitive/compare/v0.7.2...v0.8.0) (2018-10-31)


###### FEATURES

* **release:** output success & failure messages ([`a3c5bf0`](https://github.com/citycide/fugitive/commit/a3c5bf06726ebc3a05701186b5e0cc8d31d6c803))

###### BUG FIXES

* **release:** correct bad json parsing & url formation ([`9f2308b`](https://github.com/citycide/fugitive/commit/9f2308bc631888375b689af0241ea3b32248896f))
* **cli:** stop lower casing input ([`fd45062`](https://github.com/citycide/fugitive/commit/fd4506224c5129669ef34d11ac132c6ceb9d2c85))

---

<a name="v0.7.2"></a>
### [`v0.7.2`](https://github.com/citycide/fugitive/compare/v0.7.1...v0.7.2) (2018-10-30)

Patch release to kick off automated releases. No user facing changes.

---

<a name="v0.7.1"></a>
### [`v0.7.1`](https://github.com/citycide/fugitive/compare/v0.7.0...v0.7.1) (2018-10-30)

There are no user facing changes in this release, other than a possible change
to distributed release files. Versions of fugitive for the three major platforms
should now be deployed automatically on new releases &mdash; that includes
Windows, Linux, & macOS.

---

<a name="v0.7.0"></a>
### [`v0.7.0`](https://github.com/citycide/fugitive/compare/v0.6.0...v0.7.0) (2018-10-30)


###### FEATURES

* support disabling colors ([`26b6665`](https://github.com/citycide/fugitive/commit/26b66657f90455efe41d3e3e5c2c306a9446a0fc))
* add `release` command ([`53235f3`](https://github.com/citycide/fugitive/commit/53235f3bd7b6884094f4625521c75603e58f8734))
* **changelog:** elide leading newline when possible ([`fb904e5`](https://github.com/citycide/fugitive/commit/fb904e51c5c5b98c7e820a40439c07b01447701e))
* **changelog:** add options for disabling more content ([`68528c8`](https://github.com/citycide/fugitive/commit/68528c8919716b9985c2fecef9adc75ed3bcb828))
* **install:** add release & scrap to alias list ([`8375bd0`](https://github.com/citycide/fugitive/commit/8375bd017af92a54a208bafdf53a88a9053af850))

---

<a name="v0.6.0"></a>
### [`v0.6.0`](https://github.com/citycide/fugitive/compare/v0.5.0...v0.6.0) (2018-10-26)


###### FEATURES

* **changelog:** render PR references as links ([`e81b5da`](https://github.com/citycide/fugitive/commit/e81b5dadefccd6993bb132bfa15ed039d8c34855))
* **changelog:** don't render non-conforming commit messages ([`d052379`](https://github.com/citycide/fugitive/commit/d05237927c87541befa3626813e4e87fed632050))
* add `scrap` command ([`60c1a41`](https://github.com/citycide/fugitive/commit/60c1a410a6608f97713e4583909dcef3c5a7104b))
* **unstage:** add `--all` flag for unstaging all staged files ([`c771fd4`](https://github.com/citycide/fugitive/commit/c771fd45145f281ea7b335b62745c177934703e8))
* fail on unknown commands ([`b3eb775`](https://github.com/citycide/fugitive/commit/b3eb77564d3b9770eed3c50d62a8aec3e277119e))

###### PERFORMANCE

* **changelog:** tiny improvement to header parser ([`a550d81`](https://github.com/citycide/fugitive/commit/a550d812d21381b6fe28073dd67813ef81470519))

---

<a name="v0.5.0"></a>
### [`v0.5.0`](https://github.com/citycide/fugitive/compare/v0.4.0...v0.5.0) (2018-07-10)


###### FEATURES

* **config:** add `config` command ([`0c6bd99`](https://github.com/citycide/fugitive/commit/0c6bd99d32be98c2b1a11faa56e2b28da6bc71df))
* **changelog:** add `init` option for starting new changelog ([`ace43f7`](https://github.com/citycide/fugitive/commit/ace43f75b05cf75975fe70b0b5ec9c5c55e720e0))
* **changelog:** parse and render breaking changes and closures ([`27b8992`](https://github.com/citycide/fugitive/commit/27b8992f144415e43933ac6c4ef5b3e2c2b1cad9))
* use local git username if one isnt saved ([`a6b45eb`](https://github.com/citycide/fugitive/commit/a6b45eb32cdabe102a3fb6df4ad21ad8f8a1d1c1))

###### BUG FIXES

* **changelog:** handle unknown commit types ([`25a654a`](https://github.com/citycide/fugitive/commit/25a654ab62b2e3edc503f121f16487b3374c861c))

---

<a name="v0.4.0"></a>
### [`v0.4.0`](https://github.com/citycide/fugitive/compare/v0.3.1...v0.4.0) (2018-06-29)


###### FEATURES

* **changelog:** fetch tags before running; do nothing if no commits ([`05737f7`](https://github.com/citycide/fugitive/commit/05737f7948b530e461f862473fbe0c1d9befdbc9))

###### BUG FIXES

* **age,repos:** print response correctly instead of template string ([`f8ff340`](https://github.com/citycide/fugitive/commit/f8ff340de9ed75e64540d91b619aa6be43fd2a84))

---

<a name="v0.3.1"></a>
### [`v0.3.1`](https://github.com/citycide/fugitive/compare/v0.3.0...v0.3.1) (2018-06-26)


###### BUG FIXES

* **cli:** use correct colors for messages ([`3a54827`](https://github.com/citycide/fugitive/commit/3a548275ee7b35575e0e0c35ed4ff92d85d163c4))

---

<a name="v0.3.0"></a>
### [`v0.3.0`](https://github.com/citycide/fugitive/compare/v0.2.0...v0.3.0) (2018-06-26)

This release fixes a few bugs and adds a new command: `changelog`. It was used
to generate this very document :tada:. It should also improve ease of use since
every command now has its own help docs &mdash; just pass the `--help`/`-h` flag
after the command:

```shell
# get specific help for the changelog command
fugitive changelog --help

# or the open command
fugitive open -h

# and so on!
fugitive mirror -h
```

###### FEATURES

* **commands:** add `changelog` command ([`8c6ba82`](https://github.com/citycide/fugitive/commit/8c6ba826190a76cea589ba121e1e4b459db16c56))
* **install:** add `changelog` to alias list ([`8a856e7`](https://github.com/citycide/fugitive/commit/8a856e76a5749101796de86d76caee2eb78ba996))
* add command-specific help messages to all commands ([`93d150f`](https://github.com/citycide/fugitive/commit/93d150f38700fd26958d97dd6086803d832d117c))
* improve git repo retrieval strategy ([`4227489`](https://github.com/citycide/fugitive/commit/42274892922602c3fe1b5d737c418c412fe5f43f))

###### BUG FIXES

* **summary:** correct activity percentage to not be infinity ([`4548803`](https://github.com/citycide/fugitive/commit/4548803f9e39662c30356b49b34afeddab8a6941))
* **util:** fix url retrieval by normalizing git urls ([`1bc1131`](https://github.com/citycide/fugitive/commit/1bc1131a4b95a4ac6b898702d27353d1b8632bad))

---

<a name="v0.2.0"></a>
### [`v0.2.0`](https://github.com/citycide/fugitive/compare/v0.1.2...v0.2.0) (2018-05-15)


###### FEATURES

* **open:** support opening url from wsl ([`b9a7040`](https://github.com/citycide/fugitive/commit/b9a70407dd32d66bfbe37b7fcea030e06a23003f))

###### BUG FIXES

* **summary:** fix invalid commands due to whitespace ([`908b0d5`](https://github.com/citycide/fugitive/commit/908b0d576ccac2456d6c8378b0b1277cc9bba59b))

---

<a name="v0.1.2"></a>
### [`v0.1.2`](https://github.com/citycide/fugitive/compare/v0.1.1...v0.1.2) (2017-10-24)


###### FEATURES

- check environment for `git` upon running and fail with a nice message if it isn't found ([`d223d32`](https://github.com/citycide/fugitive/commit/d223d32f94e8a70d3d044ff7afb26762c9552964))
- support `--help` flag for individual subcommands ([`179e483`](https://github.com/citycide/fugitive/commit/179e483d2cfe5c14a432dc7c40e59fc451b36999))
- improve summary output & support for windows environments ([`5be619c`](https://github.com/citycide/fugitive/commit/5be619c54517a78a971999063faf3b6dab72b928))

###### BUG FIXES

- improve humanized times such as in `summary` ([`9d508e0`](https://github.com/citycide/fugitive/commit/9d508e0935d1970d8fd2c6e5a4e0e559ce9c0aea))

---

<a name="v0.1.1"></a>
### [`v0.1.1`](https://github.com/citycide/fugitive/compare/v0.1.0...v0.1.1) (2017-08-27)


First version with prebuilt binaries.

---

<a name="v0.1.0"></a>
### `v0.1.0` (2017-08-22)


Initial release.

---
