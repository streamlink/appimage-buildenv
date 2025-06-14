#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


# download{,-mirror}.savannah.gnu.org is once again offline, so use a static, but reliable mirror instead
ATTR_URL=https://mirror.netcologne.de/savannah/attr/attr-2.5.2.tar.xz
ATTR_SHA256=f2e97b0ab7ce293681ab701915766190d607a1dba7fae8a718138150b700a70b

ZSTD_URL=https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
ZSTD_SHA256=eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3

SQUASHFSTOOLS_URL=https://github.com/plougher/squashfs-tools/releases/download/4.7/squashfs-tools-4.7.tar.gz
SQUASHFSTOOLS_SHA256=f1605ef720aa0b23939a49ef4491f6e734333ccc4bda4324d330da647e105328


build_attr() {
  download_and_extract_tarball "${ATTR_URL}" "${ATTR_SHA256}" -J --strip-components=1

  ./configure \
    --prefix=/usr/local \
    --disable-dependency-tracking \
    --libexecdir=/usr/local/lib
  make
  make install
}

build_zstd() {
  download_and_extract_tarball "${ZSTD_URL}" "${ZSTD_SHA256}" -z --strip-components=1

  export PYTHONDONTWRITEBYTECODE=1
  cmake \
    -S build/cmake \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DZSTD_BUILD_CONTRIB=OFF \
    -DZSTD_BUILD_PROGRAMS=OFF \
    -DZSTD_BUILD_STATIC=OFF \
    -DZSTD_BUILD_TESTS=OFF
  cmake --build build
  cmake --install build
}

build_squashfstools() {
  download_and_extract_tarball "${SQUASHFSTOOLS_URL}" "${SQUASHFSTOOLS_SHA256}" -z --strip-components=1
  pushd squashfs-tools

  local makeoptions
  makeoptions=(
    CONFIG=1
    GZIP_SUPPORT=0
    XZ_SUPPORT=0
    LZO_SUPPORT=0
    LZ4_SUPPORT=0
    ZSTD_SUPPORT=1
    COMP_DEFAULT=zstd
    XATTR_SUPPORT=1
    USE_PREBUILT_MANPAGES=y
    SMALL_READER_THREADS=4
    BLOCK_READER_THREADS=4
    INSTALL_PREFIX=/usr/local
  )

  make "${makeoptions[@]}"
  make "${makeoptions[@]}" install

  popd
}

finalize() {
  rm -f /usr/local/lib/libattr.{a,la}
  rm -f /usr/local/share/doc/attr/CHANGES
  rm -rf /usr/local/man
  rm -rf /usr/local/share/man/man{1,3}
}

check() {
  /usr/local/bin/mksquashfs -version
}


build build_attr
build build_zstd
build build_squashfstools
finalize
check
