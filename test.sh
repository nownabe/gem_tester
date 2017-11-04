#!/bin/bash

set -x

cd /gem_tester

git clone --depth 1 $RUBY_REPO -b $RUBY_BRANCH /gem_tester/ruby

cd ruby
autoconf
cd ../build
../ruby/configure --prefix=/gem_tester/install $CONFIGURE_OPTIONS
make -j
make test-gems OPTIONS="${GEMTESTER_OPTIONS}"
