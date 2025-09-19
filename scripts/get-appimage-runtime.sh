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

EXCLUDELIST_URL=https://raw.githubusercontent.com/AppImageCommunity/pkg2appimage/19e30b276ffedf4d3b4b56bc6320f463625a74f8/excludelist
EXCLUDELIST_SHA256=50db0f894f34b169c47a5cbc0c17dbab61e9edebca5bc8269a1e6ac1bf4bdad9


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
