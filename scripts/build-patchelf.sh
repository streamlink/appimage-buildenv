#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


PATCHELF_URL=https://github.com/NixOS/patchelf/releases/download/0.16.1/patchelf-0.16.1.tar.bz2
PATCHELF_SHA256=ab915f3f4ccc463d96ce1e72685b163110f945c22aee5bc62118d57adff0ab7d


build_patchelf() {
  download_and_extract_tarball "${PATCHELF_URL}" "${PATCHELF_SHA256}" -j --strip-components=1

  ./configure \
    --prefix=/usr/local
  make
  make install
}

finalize() {
  rm -rf /usr/local/share/doc/patchelf
  rm -rf /usr/local/share/man/man1
}

check() {
  /usr/local/bin/patchelf --version
}


build build_patchelf
finalize
check
