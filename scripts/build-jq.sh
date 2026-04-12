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
    LDFLAGS="${LDFLAGS:-} -Wl,-rpath -Wl,/usr/local/lib"
  make
  make install
}

install_yq() {
  local python=/opt/python/cp313-cp313/bin/python
  local venv=/usr/local/lib/yq

  "${python}" -B -m venv --without-pip "${venv}"
  "${python}" -B -m pip \
    --python "${venv}/bin/python" \
    install \
    --root-user-action=ignore \
    --no-compile \
    --require-hashes \
    -r /dev/stdin <<EOF
yq==3.4.3 --hash=sha256:547e34bc3caacce83665fd3429bf7c85f8e8b6b9aaee3f953db1ad716ff3434d
pyyaml==6.0.3 --hash=sha256:d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f
tomlkit==0.14.0 --hash=sha256:cf00efca415dbd57575befb1f6634c4f42d2d87dbba376128adb42c121b87064
xmltodict==1.0.4 --hash=sha256:6d94c9f834dd9e44514162799d344d815a3a4faec913717a9ecbfa5be1bb8e61
argcomplete==3.6.3 --hash=sha256:62e8ed4fd6a45864acc8235409461b72c9a28ee785a2011cc5eb78318786c89c
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
