#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


case "${AUDITWHEEL_ARCH}" in
  aarch64)
    APPIMAGETOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-aarch64.AppImage
    APPIMAGETOOL_SHA256=334e77beb67fc1e71856c29d5f3f324ca77b0fde7a840fdd14bd3b88c25c341f
    ;;
  i686)
    APPIMAGETOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-i686.AppImage
    APPIMAGETOOL_SHA256=104978205c888cb2ad42d1799e03d4621cb9a6027cfb375d069b394a82ff15d1
    ;;
  x86_64)
    APPIMAGETOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage
    APPIMAGETOOL_SHA256=df3baf5ca5facbecfc2f3fa6713c29ab9cefa8fd8c1eac5d283b79cab33e4acb
    ;;
  *)
    exit 1
    ;;
esac

EXCLUDELIST_URL=https://raw.githubusercontent.com/AppImage/pkg2appimage/d61672ff4f90cf793a0bee7b056186fcdeb9b510/excludelist
EXCLUDELIST_SHA256=1a23ff720850b0c36d604663001b0ad9560b85ad51e0f3aac452714a9b67e042


build_appimagetool() {
  download "${APPIMAGETOOL_URL}" "${APPIMAGETOOL_SHA256}" appimagetool.appimage

  sed -i 's|\x41\x49\x02|\x00\x00\x00|' appimagetool.appimage
  chmod +x appimagetool.appimage
  ./appimagetool.appimage --appimage-extract

  cat > ./squashfs-root/usr/lib/appimagekit/mksquashfs <<EOF
#!/bin/sh
/usr/local/bin/mksquashfs \$(echo "\$@" | sed -e "s/-mkfs-time 0//")
EOF
  mv squashfs-root /opt/appimagetool
  ln -s /opt/appimagetool/AppRun /usr/local/bin/appimagetool
}

build_excludelist() {
  mkdir -p /usr/local/share/appimage
  download "${EXCLUDELIST_URL}" "${EXCLUDELIST_SHA256}" /usr/local/share/appimage/excludelist
}

check() {
  /usr/local/bin/appimagetool --version
}


build build_appimagetool
build build_excludelist
check
