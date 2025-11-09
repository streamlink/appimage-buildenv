#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


case "${AUDITWHEEL_ARCH}" in
  aarch64)
    TYPE2_RUNTIME_URL=https://github.com/streamlink/appimage-type2-runtime/releases/download/20251109-1/runtime-aarch64
    TYPE2_RUNTIME_SHA256=d0b1d4114e7cc74d6780b05dded24256d6865c840c9b4ae773f2a0c40dd8fd49
    ;;
  x86_64)
    TYPE2_RUNTIME_URL=https://github.com/streamlink/appimage-type2-runtime/releases/download/20251109-1/runtime-x86_64
    TYPE2_RUNTIME_SHA256=81b3fb025e05fe5f35420d65af6e268da2dc78d63c1f3651539c7f33759dc8f6
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
