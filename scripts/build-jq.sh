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

install_yq() {
  local python=/opt/python/cp311-cp311/bin/python
  local venv=/usr/local/lib/yq

  export PYTHONDONTWRITEBYTECODE=1
  "${python}" -B -m venv --without-pip "${venv}"
  "${python}" -B -m pip \
    --python "${venv}/bin/python" \
    install \
    --root-user-action=ignore \
    --no-compile \
    --require-hashes \
    -r /dev/stdin <<EOF
yq==3.2.3 --hash=sha256:b50c91894dad9894d1d36ea77d5722d5495cac9482d2351e55089360a90709ae
pyyaml==6.0.1 --hash=sha256:bfdf460b1736c775f2ba9f6a92bca30bc2095067b8a9d77876d1fad6cc3b4a43
tomlkit==0.12.1 --hash=sha256:712cbd236609acc6a3e2e97253dfc52d4c2082982a88f61b640ecf0817eab899
xmltodict==0.13.0 --hash=sha256:aa89e8fd76320154a40d19a0df04a4695fb9dc5ba977cbb68ab3e4eb225e7852
argcomplete==3.1.2 --hash=sha256:d97c036d12a752d1079f190bc1521c545b941fda89ad85d15afa909b4d1b9a99
EOF

  ln -s "${venv}/bin/yq" /usr/local/bin/yq
  ln -s "${venv}/bin/tomlq" /usr/local/bin/tomlq
  ln -s "${venv}/bin/xq" /usr/local/bin/xq
}

finalize() {
  rm -f /usr/local/lib/lib{onig,jq}.{a,la}
  rm -rf /usr/local/share/doc/jq
  rm -f /usr/local/share/man/man1/jq.1

  rm -rf /root/.cache
  find
}

check() {
  /usr/local/bin/jq --version
}


build build_oniguruma
build build_jq
install_yq
finalize
check
