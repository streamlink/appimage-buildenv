Streamlink appimage buildenv
====

Docker image build config for building [appimages](https://appimage.org/) for [Streamlink](https://github.com/streamlink/streamlink) and [Streamlink Twitch GUI](https://github.com/streamlink/streamlink-twitch-gui).

## Images

- [`ghcr.io/streamlink/appimage-buildenv-x86_64`](https://github.com/streamlink/appimage-buildenv/pkgs/container/appimage-buildenv-x86_64)
- [`ghcr.io/streamlink/appimage-buildenv-aarch64`](https://github.com/streamlink/appimage-buildenv/pkgs/container/appimage-buildenv-aarch64)

Based on the [`pypa/manylinux`](https://github.com/pypa/manylinux) images (`manylinux_2_28`), which are based on the official [`almalinux:8`](https://hub.docker.com/_/almalinux) images.

### Contents

- [`patchelf`](https://github.com/NixOS/patchelf)
- [`jq`](https://github.com/jqlang/jq) + [`yq`](https://github.com/kislyuk/yq)
- [`squashfs-tools`](https://github.com/plougher/squashfs-tools) with [`zstd`](https://github.com/facebook/zstd) support
- [`AppImage type2 runtime`](https://github.com/streamlink/appimage-type2-runtime)
- [`zsync2`](https://github.com/AppImageCommunity/zsync2)
