ARG BASEIMAGE=almalinux:8
FROM $BASEIMAGE AS base

ENV PYTHONDONTWRITEBYTECODE=1

RUN dnf install -y --setopt=install_weak_deps=False \
      openssl-devel \
 && dnf clean all \
 && rm -rf /var/cache/dnf

COPY ./scripts /scripts

RUN /scripts/build-patchelf.sh
RUN /scripts/build-jq.sh
RUN /scripts/build-squashfstools.sh
RUN /scripts/get-appimage-runtime.sh
RUN /scripts/build-zsync2.sh

RUN rm -rf /scripts
