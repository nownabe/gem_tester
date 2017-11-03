ARG tag
FROM ${tag}
LABEL maintainer="nownabe@gmail.com"

ARG preprocess
ARG install_command
ARG build_deps
ARG test_deps
ARG postprocess

# Preprocess
RUN ${preprocess} \
  && ${install_command} ${build_deps} \
  && ${install_command} ${test_deps} \
  && ${postprocess} \
  && mkdir -p /gem_tester/build

WORKDIR /gem_tester

COPY test.sh /gem_tester/test.sh

ENV RUBY_REPO "https://github.com/nownabe/ruby"
ENV RUBY_BRANCH "gem_tester-trunk"
# TODO: ENV CONDITION_YAML embedded
ENV RUBY_CONFIGURE_OPTIONS "--enable-shared"
# TODO: ENV TEST_GEMS
ENV GEMS "rspec-core"

CMD bash /gem_tester/test.sh
