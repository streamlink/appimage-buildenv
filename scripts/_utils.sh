#!/usr/bin/env bash
set -exuo pipefail


MAKEFLAGS=-j$(nproc)
export MAKEFLAGS


download() {
  local url sha256 file
  url="${1}"
  sha256="${2}"
  file="${3}"

  curl -fgSL \
    -A "$(curl -V | awk '{print $1 "/" $2; exit}')" \
    --retry 3 --retry-delay 3 \
    -o "${3}" \
    "${1}"
  sha256sum --check <<< "${2}  ${3}"
}

extract_tarball() {
  local file="${1}"
  shift
  tar -C . -x "${@}" -f "${file}"
}

download_and_extract_tarball() {
  local url sha256 file
  url="${1}"
  sha256="${2}"
  file="$(basename -- "${url}")"
  shift 2
  download "${url}" "${sha256}" "${file}"
  extract_tarball "${file}" "${@}"
}

build() {
  local dir build_command
  build_command="${1}"
  shift

  dir=$(mktemp -d || exit 255)
  pushd "${dir}"

  "$build_command" "${@}"

  popd
  rm -rf "${dir}"
}
