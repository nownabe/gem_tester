ARG tag
FROM ${tag}
LABEL maintainer="nownabe@gmail.com"

ARG tag
ARG preprocess
ARG install_command
ARG build_deps
ARG test_deps
ARG postprocess

# Preprocess
RUN set -x \
  && echo ${tag} \
  && echo ${preprocess} \
  && echo ${install_command} \
  && echo ${build_deps} \
  && echo ${test_deps} \
  && echo ${postprocess} \
  && ${preprocess} \
  && ${install_command} ${build_deps} \
  && ${install_command} ${test_deps}
RUN set -x \
  && ${postprocess} \
  && mkdir -p /gem_tester/build

# Build dependencies
# RUN apt-get install -y \
#   git ruby autoconf bison gcc make zlib1g-dev libffi-dev \
#   libreadline-dev libgdbm-dev libssl-dev

# Test dependencies
# RUN apt-get install -y \
#   libncurses5-dev g++ libxml2-dev default-libmysqlclient-dev libpq-dev \
#   libsqlite3-dev libidn11-dev nodejs libcurl4-gnutls-dev cmake \
#   lsof libfcgi-dev libtool zip

# Postprocess
# RUN ${postprocess}

# RUN mkdir /gem_tester
WORKDIR /gem_tester
# RUN mkdir /gem_tester/build

COPY test.sh /gem_tester/test.sh

ENV RUBY_REPO "https://github.com/nownabe/ruby"
ENV RUBY_BRANCH "gem_tester-trunk"
# TODO: ENV CONDITION_YAML embedded
ENV RUBY_CONFIGURE_OPTIONS "--enable-shared"
# TODO: ENV TEST_GEMS
ENV GEMS "rspec-core"

CMD bash /gem_tester/test.sh
