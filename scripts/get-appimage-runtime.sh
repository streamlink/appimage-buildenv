#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


case "${AUDITWHEEL_ARCH}" in
  aarch64)
    TYPE2_RUNTIME_URL=https://github.com/streamlink/appimage-type2-runtime/releases/download/20250523-1/runtime-aarch64
    TYPE2_RUNTIME_SHA256=2a4c3e0f0ee14133eb5c03dd6962666c9cbb6dcce51a5b3f2abf8b0619bf986c
    ;;
  x86_64)
    TYPE2_RUNTIME_URL=https://github.com/streamlink/appimage-type2-runtime/releases/download/20250523-1/runtime-x86_64
    TYPE2_RUNTIME_SHA256=10d6221e674b3667b6a014b81f67e7f24cbd7584cb936059e14ad5e4df1cd676
    ;;
  *)
    exit 1
    ;;
esac

EXCLUDELIST_URL=https://raw.githubusercontent.com/AppImage/pkg2appimage/d61672ff4f90cf793a0bee7b056186fcdeb9b510/excludelist
EXCLUDELIST_SHA256=1a23ff720850b0c36d604663001b0ad9560b85ad51e0f3aac452714a9b67e042


get_type2_runtime() {
  download "${TYPE2_RUNTIME_URL}" "${TYPE2_RUNTIME_SHA256}" runtime
  install -Dm744 runtime /usr/local/share/appimage/runtime
}

get_excludelist() {
  download "${EXCLUDELIST_URL}" "${EXCLUDELIST_SHA256}" /usr/local/share/appimage/excludelist
}

check() {
  /usr/local/share/appimage/runtime --appimage-help
}


build get_type2_runtime
build get_excludelist
check
