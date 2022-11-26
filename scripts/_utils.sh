#!/usr/bin/env bash
set -exuo pipefail


export MAKEFLAGS=-j$(nproc)


prepare() {
  mkdir /build
  pushd /build
}

cleanup() {
  popd
  rm -rf /build
}

download() {
  local url="${1}"
  local sha256="${2}"
  local file="${3}"
  curl -fSL -o "${3}" "${1}"
  sha256sum --check <<< "${2}  ${3}"
}

extract_tarball() {
  local file="${1}"
  shift
  tar -C . -x "${@}" -f "${file}"
}

download_and_extract_tarball() {
  local url="${1}"
  local sha256="${2}"
  local file="$(basename -- "${url}")"
  shift 2
  download "${url}" "${sha256}" "${file}"
  extract_tarball "${file}" "${@}"
}

build() {
  local _build="${1}"
  shift
  prepare
  "$_build" "${@}"
  cleanup
}
