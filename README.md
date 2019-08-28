# AVDL Compiler

[![Travis CI](https://travis-ci.org/keybase/node-avdl-compiler.svg?branch=master)](https://travis-ci.org/keybase/node-avdl-compiler)
[![npm version](https://badge.fury.io/js/avdl-compiler.svg)](https://badge.fury.io/js/avdl-compiler)

AVDL compiler to Go, Python, and/or TypeScript written in IcedCoffeeScript.

Notably used by Keybase to compile our protocol definition files into usable types by our [Go](https://github.com/keybase/go-keybase-chat-bot), [Python](https://github.com/keybase/pykeybasebot), and [TypeScript](https://github.com/keybase/keybase-bot) bots.

## Development Setup and Testing

Found a bug or want to support a new language? We accept pull requests.

```
make install
make test
```
