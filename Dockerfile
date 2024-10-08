ARG BASEIMAGE=almalinux:8
FROM $BASEIMAGE AS base

COPY ./scripts /scripts

RUN /scripts/build-patchelf.sh
RUN /scripts/build-jq.sh
RUN /scripts/build-squashfstools.sh
RUN /scripts/build-appimagetool.sh

RUN rm -rf /scripts
