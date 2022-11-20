#!/usr/bin/env bash
set -exuo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/_utils.sh"


case "$(uname -m)" in
  aarch64)
    APPIMAGETOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-aarch64.AppImage
    APPIMAGETOOL_SHA256=c9d058310a4e04b9fbbd81340fff2b5fb44943a630b31881e321719f271bd41a
    ;;
  i686)
    APPIMAGETOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-i686.AppImage
    APPIMAGETOOL_SHA256=3af6839ab6d236cd62ace9fbc2f86487f0bf104f521d82da6dea4dab8d3ce4ca
    ;;
  x86_64)
    APPIMAGETOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage
    APPIMAGETOOL_SHA256=d918b4df547b388ef253f3c9e7f6529ca81a885395c31f619d9aaf7030499a13
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
/usr/local/bin/mksquashfs \$(echo "\$@" | sed -e "s/-mkfs-fixed-time 0//")
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


build_appimagetool
build_excludelist
check
