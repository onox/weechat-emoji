[![Build status](https://github.com/onox/weechat-emoji/actions/workflows/build.yaml/badge.svg)](https://github.com/onox/weechat-emoji/actions/workflows/build.yaml)
[![License](https://img.shields.io/github/license/onox/weechat-emoji.svg?color=blue)](https://github.com/onox/weechat-emoji/blob/master/LICENSE)
[![Alire crate](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/weechat_emoji.json)](https://alire.ada.dev/crates/weechat_emoji.html)
[![GitHub release](https://img.shields.io/github/release/onox/weechat-emoji.svg)](https://github.com/onox/weechat-emoji/releases/latest)
[![IRC](https://img.shields.io/badge/IRC-%23ada%20on%20libera.chat-orange.svg)](https://libera.chat)
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/ada-lang/Lobby)

# weechat-emoji

A [WeeChat][url-weechat] plug-in written in Ada 2012 that displays
emoji.

Uses the [weechat-ada][url-weechat-ada] bindings.

## Dependencies

In order to build the plug-in, you need to have:

 * An Ada 2012 compiler

 * [Alire][url-alire]
 
 * `make`

## Installing dependencies on Ubuntu 18.04 LTS

Install the dependencies using apt:

```
$ sudo apt install gnat-7 gprbuild make
```

and then install Alire.

## Installation

A Makefile is provided to build the source code. Use `make` to build
the source code:

```
$ make
```

Install the `gcc` package if you get a message about
"plugin needed to handle lto object":

```sh
$ sudo apt install gcc
```

After having compiled the source code,
the plug-in can be installed to `~/.weechat/plugins/` by executing:

```
$ make install
```

## Contributing

Read the [contributing guidelines][url-contributing] if you want to add
a bugfix or an improvement.

## License

This plug-in is licensed under the [Apache License 2.0][url-apache].
The first line of each Ada file should contain an SPDX license identifier tag that
refers to this license:

    SPDX-License-Identifier: Apache-2.0

  [url-alire]: https://alire.ada.dev/
  [url-apache]: https://opensource.org/licenses/Apache-2.0
  [url-contributing]: /CONTRIBUTING.md
  [url-weechat]: https://weechat.org/
  [url-weechat-ada]: https://github.com/onox/weechat-ada
