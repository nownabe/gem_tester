#!/bin/bash

set -e

function install_build_dependencies_ubuntu() {
  sudo apt-get install -y \
    git ruby autoconf bison gcc make zlib1g-dev libffi-dev \
    libreadline-dev libgdbm-dev libssl-dev
}

function install_test_dependencies_ubuntu() {
  sudo apt-get install -y \
    g++ libncurses5-dev ragel libxml2-dev libpq-dev libsqlite3-dev \
    libfcgi-dev libmysqlclient-dev libidn11-dev libcurl4-gnutls-dev \
    nodejs libtool cmake
}

function install_build_dependencies_centos() {
  sudo yum install -y \
    git ruby autoconf gcc bison bzip2 openssl-devel libyaml-devel \
    libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
}

function install_test_dependencies_centos() {
  sudo yum install -y epel-release
  sudo yum install -y \
    gcc-c++ libxml2-devel mysql-devel postgresql-devel sqlite-devel \
    fcgi-devel libcurl-devel lsof cmake libtool nodejs libidn-devel \
    wget
}

function install_build_dependencies_debian() {
  sudo apt-get install -y \
    git ruby autoconf bison gcc make zlib1g-dev libffi-dev \
    libreadline-dev libgdbm-dev libssl-dev
}

function install_test_dependencies_debian() {
  sudo apt-get install -y \
    ncurses-dev g++ libxml2-dev libmsqlclient-dev libpq-dev \
    libsqlite3-dev libidn11-dev nodejs libcurl4-gnutls-dev cmake \
    lsof libfcgi-dev libtool zip
}

if [[ -f /etc/lsb-release ]]; then
  . /etc/lsb-release
  distrib_id=$DISTRIB_ID
  distrib_release=$DISTRIB_RELEASE
elif [[ -f /etc/redhat-release ]]; then
  distrib_id=$(cut -d' ' -f1 /etc/redhat-release)
  distrib_release=$(cut -d' ' -f3 /etc/redhat-release)
elif [[ -f /etc/debian_version ]]; then
  distrib_id=Debian
  distrib_release=$(cat /etc/debian_version)
fi

echo "Distribution: ${distrib_id} (${distrib_release})"

case "$distrib_id" in
  "Ubuntu")
    install_build_dependencies_ubuntu $distrib_release
    install_test_dependencies_ubuntu $distrib_release
    ;;
  "CentOS")
    install_build_dependencies_centos $distrib_release
    install_test_dependencies_centos $distrib_release
    ;;
  "Debian")
    install_build_dependencies_debian $distrib_release
    install_test_dependencies_debian $distrib_release
    ;;
  *)
    echo "Unknown distribution"
    ;;
esac


mkdir gemtester
cd gemtester

git clone https://github.com/nownabe/ruby.git -b gem_tester-2.4.2

cd ruby
autoconf
cd ..
mkdir build
cd build
../ruby/configure --prefix=`pwd`/../install $CONFIGURE_OPTIONS
make -j

make test-gems
