ARG BASEIMAGE=almalinux:8
FROM $BASEIMAGE AS base

ENV PYTHONDONTWRITEBYTECODE=1

RUN dnf install -y --setopt=install_weak_deps=False \
      openssl-devel \
 && dnf clean all \
 && rm -rf /var/cache/dnf

RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/build-patchelf.sh
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/build-jq.sh
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/build-squashfstools.sh
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/get-appimage-runtime.sh
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/build-zsync2.sh
