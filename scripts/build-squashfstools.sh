#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


ATTR_URL=https://download-mirror.savannah.gnu.org/releases/attr/attr-2.5.1.tar.xz
ATTR_SHA256=db448a626f9313a1a970d636767316a8da32aede70518b8050fa0de7947adc32

SQUASHFSTOOLS_URL=https://github.com/plougher/squashfs-tools/archive/0f5666a3b250d7732211c188b58d11b36744c75e.tar.gz
SQUASHFSTOOLS_SHA256=c3ee24dff1bb3f868a6bea834504e5c6c057ed95fee2d0d9f546683fe56d8391


build_attr() {
  download_and_extract_tarball "${ATTR_URL}" "${ATTR_SHA256}" -J --strip-components=1

  ./configure \
    --prefix=/usr/local \
    --disable-dependency-tracking \
    --libexecdir=/usr/local/lib
  make
  make install
}

build_squashfstools() {
  download_and_extract_tarball "${SQUASHFSTOOLS_URL}" "${SQUASHFSTOOLS_SHA256}" -z --strip-components=1
  pushd squashfs-tools

  make \
    GZIP_SUPPORT=1 \
    XZ_SUPPORT=0 \
    LZO_SUPPORT=0 \
    LZMA_XZ_SUPPORT=0 \
    LZ4_SUPPORT=0 \
    ZSTD_SUPPORT=0 \
    XATTR_SUPPORT=1
  make install \
    INSTALL_PREFIX=/usr/local

  popd
}

finalize() {
  rm -f /usr/local/lib/libattr.{a,la}
  rm -f /usr/local/share/man/man1/{,get{,f},set{,f}}attr*.1
  rm -f /usr/local/share/man/man3/attr_*.3
  rm -f /usr/local/share/man/man1/{{mk,un}squashfs,sqfs{cat,tar}}*.1
}

check() {
  /usr/local/bin/mksquashfs -version
}


build build_attr
build build_squashfstools
finalize
check
