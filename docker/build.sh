#!/bin/bash

basedir=$(dirname $(cd $(dirname $0) && pwd))

cd $basedir/docker

for pf in $(ls platforms); do
  . platforms/${pf}
  docker build \
    -t nownabe/gem_tester:${pf} \
    -f Dockerfile \
    --build-arg "tag=${tag}" \
    --build-arg "preprocess=${preprocess}" \
    --build-arg "install_command=${install_command}" \
    --build-arg "build_deps=${build_deps}" \
    --build-arg "test_deps=${test_deps}" \
    --build-arg "postprocess=${postprocess}" \
    .
  docker push nownabe/gem_tester:${pf}
done
