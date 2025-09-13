ARG BASEIMAGE=almalinux:8
FROM $BASEIMAGE AS base

ENV PYTHONDONTWRITEBYTECODE=1

COPY ./scripts /scripts

RUN /scripts/build-patchelf.sh
RUN /scripts/build-jq.sh
RUN /scripts/build-squashfstools.sh
RUN /scripts/get-appimage-runtime.sh

RUN rm -rf /scripts
