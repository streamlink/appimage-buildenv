#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


LIBGPG_ERROR_URL=https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.55.tar.gz
LIBGPG_ERROR_SHA256=bda09f51d7ed64565e41069d782bfcc4984aed908ae68bee01fb692b64ea96e2

LIBGCRYPT_URL=https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.11.2.tar.gz
LIBGCRYPT_SHA256=56f6eb6871a5431e6700fdf70962c76eac0aa4bc6bceab68da4907e3fcb929e0

ZSYNC2_URL=https://github.com/AppImageCommunity/zsync2/archive/f855a8b4d7c2533b62e0c967da59e21bffd44ac3.tar.gz
ZSYNC2_SHA256=2c70a23f2919c4f75bfe6c7a17b24c8895b7fdfff7163b915153284ef746f76f


build_libgpg-error() {
  download_and_extract_tarball "${LIBGPG_ERROR_URL}" "${LIBGPG_ERROR_SHA256}" -z --strip-components=1

  ./configure \
    --prefix=/usr/local \
    --disable-nls \
    --disable-languages \
    --disable-doc \
    --disable-tests
  make
  make install
}

build_libgcrypt() {
  download_and_extract_tarball "${LIBGCRYPT_URL}" "${LIBGCRYPT_SHA256}" -z --strip-components=1

  ./configure \
    --prefix=/usr/local \
    --disable-static \
    --disable-padlock-support \
    --disable-doc
  make LDFLAGS=-Wl,-rpath,/usr/local/lib
  make install
}

build_zsync2() {
  download_and_extract_tarball "${ZSYNC2_URL}" "${ZSYNC2_SHA256}" -z --strip-components=1

  # shellcheck disable=SC2016
  sed -E -i \
    -e 's|INSTALL_RPATH "\\\$ORIGIN/../\$\{CMAKE_INSTALL_LIBDIR\}"|INSTALL_RPATH "/usr/local/lib:/usr/local/lib64"|' \
    src/CMakeLists.txt

  (
    export CFLAGS=-Wno-incompatible-pointer-types
    cmake -B build \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_POLICY_VERSION_MINIMUM="3.5"
    make -C build
    make -C build install
  )
}

finalize() {
  rm -f /usr/local/lib64/*.a
}

check() {
  ldd /usr/local/bin/zsyncmake2
}


build build_libgpg-error
build build_libgcrypt
build build_zsync2
finalize
check
