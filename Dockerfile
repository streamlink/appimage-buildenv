ARG BASEIMAGE=almalinux:8
FROM $BASEIMAGE AS base

ENV PYTHONDONTWRITEBYTECODE=1

FROM base AS dnf_deps
RUN dnf install -y --setopt=install_weak_deps=False \
      openssl-devel \
 && dnf clean all \
 && rm -rf /var/cache/dnf

FROM base AS build_patchelf
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/build-patchelf.sh

FROM base AS build_jq
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/build-jq.sh

FROM base AS build_squashfstools
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/build-squashfstools.sh

FROM base AS get_appimage_runtime
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/get-appimage-runtime.sh

FROM dnf_deps AS build_zsync2
RUN --mount=type=bind,source=./scripts,target=/scripts /scripts/build-zsync2.sh

FROM base
COPY --from=build_patchelf /usr/local /usr/local/
COPY --from=build_jq /usr/local /usr/local/
COPY --from=build_squashfstools /usr/local /usr/local/
COPY --from=get_appimage_runtime /usr/local /usr/local/
COPY --from=build_zsync2 /usr/local /usr/local/
