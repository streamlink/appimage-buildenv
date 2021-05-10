Streamlink appimage buildenv
====

Docker image build config for building [appimages](https://appimage.org/) for [Streamlink](https://github.com/streamlink/streamlink) and [Streamlink Twitch GUI](https://github.com/streamlink/streamlink-twitch-gui).

## Images

- [`ghcr.io/streamlink/appimage-buildenv-x86_64`](https://github.com/orgs/streamlink/packages/container/appimage-buildenv-x86_64)
- [`ghcr.io/streamlink/appimage-buildenv-i686`](https://github.com/orgs/streamlink/packages/container/appimage-buildenv-i686)
- [`ghcr.io/streamlink/appimage-buildenv-aarch64`](https://github.com/orgs/streamlink/packages/container/appimage-buildenv-aarch64)

Based on the [`quay.io/pypa/manylinux2014_*`](https://github.com/pypa/manylinux) images, which are based on the official [`centos:7`](https://hub.docker.com/_/centos) images.

### Contents

- updated [`squashfs-tools`](https://github.com/plougher/squashfs-tools) with support for reproducible builds
- prebuilt [`appimagetool`](https://github.com/AppImage/AppImageKit) with applied fixes
- appimage library [`excludelist`](https://github.com/AppImage/pkg2appimage)
