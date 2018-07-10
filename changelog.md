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
