Docker Images for GemTester
===========================

[![Build Status](https://travis-ci.org/nownabe/gem_tester-docker.svg?branch=master)](https://travis-ci.org/nownabe/gem_tester-docker)

[DockerHub](https://hub.docker.com/r/nownabe/gem_tester/)

# Tags
* centos-7
* debian-stretch

# Usage

To run GemTester, run a `test.sh` in a GemTester docker image.
For example:

```bash
docker run nownabe/gem_tester:debian-stretch
```

## Environment variables

| Name | Default | Description |
|---|---|---|
| `RUBY_REPO` | `https://github.com/nownabe/ruby` | Repository of Ruby. |
| `RUBY_BRANCH` | `gem_tester-trunk` | Branch or tag of Ruby. |
| `RUBY_CONFIGURE_OPTIONS` | `--enable-shared` | Options for `./configure` of Ruby. |
| `TEST_GEMS` | | Gems to be tested. |
| `GEMTESTER_OPTIONS` | `--shallow` | Options for GemTester. |

Default value is very temporary.

# Development
## Build

Run `./build.sh` to build docker images and push them to DockerHub.

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nownabe/gem_tester-docker.

# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
