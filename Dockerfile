ARG BASEIMAGE=centos:7
FROM $BASEIMAGE

# squashfstools
RUN export SQUASHFSTOOLS_URL=https://github.com/plougher/squashfs-tools/archive/c37bb4da4a5fa8c1cf114237ba364692dd522262.tar.gz \
 && export SQUASHFSTOOLS_SHA256=2b26783a0d4a172b18be96e73e8458eba8d2bb3361f72dd13dbd1d7fbf6a5e9a \
 && set -x && mkdir /build && cd /build \
 && curl -SL -o squashfstools.tar.gz "${SQUASHFSTOOLS_URL}" \
 && sha256sum --check <<< "${SQUASHFSTOOLS_SHA256}  squashfstools.tar.gz" \
 && tar -C . --strip-components=1 -xzf squashfstools.tar.gz \
 && cd squashfs-tools \
 && yum install -q -y zlib-devel libattr-devel \
 && make \
      GZIP_SUPPORT=1 \
      XZ_SUPPORT=0 \
      LZO_SUPPORT=0 \
      LZMA_XZ_SUPPORT=0 \
      LZ4_SUPPORT=0 \
      ZSTD_SUPPORT=0 \
      XATTR_SUPPORT=1 \
 && make install \
      INSTALL_DIR=/usr/local/bin \
 && /usr/local/bin/mksquashfs -version | head -n1 \
 && rm -rf /build

# appimagetool
ARG APPIMAGETOOL_URL
ARG APPIMAGETOOL_SHA256
RUN set -x && mkdir /build && cd /build \
 && curl -SL -o appimagetool.appimage "${APPIMAGETOOL_URL}" \
 && sha256sum --check <<< "${APPIMAGETOOL_SHA256}  appimagetool.appimage" \
 && sed -i 's|\x41\x49\x02|\x00\x00\x00|' appimagetool.appimage \
 && chmod +x appimagetool.appimage \
 && ./appimagetool.appimage --appimage-extract \
 && echo $'#!/bin/sh\n/usr/local/bin/mksquashfs $(echo "$@" | sed -e "s/-mkfs-fixed-time 0//")\n' \
      > ./squashfs-root/usr/lib/appimagekit/mksquashfs \
 && mv squashfs-root /opt/appimagetool \
 && ln -s /opt/appimagetool/AppRun /usr/local/bin/appimagetool \
 && /usr/local/bin/appimagetool --version \
 && rm -rf /build

# appimage library excludelist
RUN export EXCLUDELIST_URL=https://raw.githubusercontent.com/AppImage/pkg2appimage/d61672ff4f90cf793a0bee7b056186fcdeb9b510/excludelist \
 && export EXCLUDELIST_SHA256=1a23ff720850b0c36d604663001b0ad9560b85ad51e0f3aac452714a9b67e042 \
 && set -x \
 && mkdir -p /usr/local/share/appimage \
 && curl -SL -o /usr/local/share/appimage/excludelist "${EXCLUDELIST_URL}" \
 && sha256sum --check <<< "${EXCLUDELIST_SHA256}  /usr/local/share/appimage/excludelist"
