#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


ONIGURUMA_URL=https://github.com/kkos/oniguruma/releases/download/v6.9.8/onig-6.9.8.tar.gz
ONIGURUMA_SHA256=28cd62c1464623c7910565fb1ccaaa0104b2fe8b12bcd646e81f73b47535213e

JQ_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-1.6.tar.gz
JQ_SHA256=5de8c8e29aaa3fb9cc6b47bb27299f271354ebb72514e3accadc7d38b5bbaa72


build_oniguruma() {
  download_and_extract_tarball "${ONIGURUMA_URL}" "${ONIGURUMA_SHA256}" -z --strip-components=1

  ./configure \
    --prefix=/usr/local \
    --disable-dependency-tracking \
    --enable-posix-api
  make
  make install
}

build_jq() {
  download_and_extract_tarball "${JQ_URL}" "${JQ_SHA256}" -z --strip-components=1

  ./configure \
    --prefix=/usr/local \
    --disable-dependency-tracking \
    --with-oniguruma=/usr/local
  make
  make install
}

finalize() {
  rm -f /usr/local/lib/lib{onig,jq}.{a,la}
  rm -rf /usr/local/share/doc/jq
  rm -f /usr/local/share/man/man1/jq.1
}

check() {
  /usr/local/bin/jq --version
}


build build_oniguruma
build build_jq
finalize
check
