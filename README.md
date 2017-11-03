Docker Images for GemTester
===========================

# Usage
To run GemTester, run a `test.sh` in a GemTester docker image.
For example:

```bash
docker run nownabe/gem_tester:debian-stretch
```

## Environment Variables
* `RUBY_REPO`: Repository of Ruby.
* `RUBY_BRANCH`: Branch or tag of Ruby.
* `RUBY_CONFIGURE_OPTIONS`: Options for `./configure` of Ruby.
* `GEMS`: Gems to be tested.


# Development
## Build
Run `./build.sh` to build docker images and push them to DockerHub.

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nownabe/gem_tester-docker.

# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
