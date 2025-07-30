#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


JQ_URL=https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-1.8.1.tar.gz
JQ_SHA256=2be64e7129cecb11d5906290eba10af694fb9e3e7f9fc208a311dc33ca837eb0


build_jq() {
  download_and_extract_tarball "${JQ_URL}" "${JQ_SHA256}" -z --strip-components=1

  ./configure \
    --prefix=/usr/local \
    --disable-docs \
    --with-oniguruma=builtin \
    --enable-static \
    --enable-all-static
  make
  make install
}

install_yq() {
  local python=/opt/python/cp313-cp313/bin/python
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
yq==3.4.3 --hash=sha256:547e34bc3caacce83665fd3429bf7c85f8e8b6b9aaee3f953db1ad716ff3434d
pyyaml==6.0.2 --hash=sha256:d584d9ec91ad65861cc08d42e834324ef890a082e591037abe114850ff7bbc3e
tomlkit==0.13.3 --hash=sha256:c89c649d79ee40629a9fda55f8ace8c6a1b42deb912b2a8fd8d942ddadb606b0
xmltodict==0.14.2 --hash=sha256:20cc7d723ed729276e808f26fb6b3599f786cbc37e06c65e192ba77c40f20aac
argcomplete==3.6.2 --hash=sha256:65b3133a29ad53fb42c48cf5114752c7ab66c1c38544fdf6460f450c09b42591
EOF

  ln -s "${venv}/bin/yq" /usr/local/bin/yq
  ln -s "${venv}/bin/tomlq" /usr/local/bin/tomlq
  ln -s "${venv}/bin/xq" /usr/local/bin/xq
}

finalize() {
  rm -f /usr/local/lib/lib{onig,jq}.{a,la}
  rm -rf /usr/local/share/doc/jq
  rm -rf /usr/local/share/man/man1

  rm -rf /root/.cache
}

check() {
  /usr/local/bin/jq --version
}


build build_jq
install_yq
finalize
check
