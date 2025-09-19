#!/usr/bin/env bash
set -exuo pipefail


PREFIX="/opt/python/cp${1/./}-cp${1/./}"
PYTHON_X_Y="python${1}"
OUTPUT="${2}"


declare -A excludelist
while read -r lib; do
  excludelist["${lib}"]="${lib}"
done <<< "$(sed -e '/#.*/d; /^[[:space:]]*|[[:space:]]*$/d; /^$/d' /usr/local/share/appimage/excludelist)"


libraries=()


find_libs() {
  local file
  traverse "${PREFIX}/bin/${PYTHON_X_Y}" "${PREFIX}/lib" false
  while read -r file; do
    traverse "${file}" "${PREFIX}/lib" false
  done <<< "$(find "${PREFIX}/lib/${PYTHON_X_Y}/lib-dynload" -type f -name '*.so' -print)"
  while read -r file; do
    traverse "${file}" "${PREFIX}/lib" true
  done <<< "$(find "${PREFIX}/lib" -type f -name 'lib*.so*' -print)"
}

traverse() {
  local path="${1}"
  local libdir="${2}"
  local recursive="${3:-false}"

  local deps
  mapfile -t deps < <(ldd "${path}" 2>/dev/null | grep -E ' => \S+' | sed -E 's/.+ => (.+) \(0x.+/\1/')

  for dep in "${deps[@]}"; do
    local name
    name=$(basename "${dep}")
    [[ -n "${excludelist[${name}]:-}" ]] && continue

    local target="${libdir}/${name}"
    [[ -f "${target}" ]] && continue

    libraries+=("${dep}")
    if [[ "${recursive}" == true ]]; then
      traverse "${target}" "${libdir}" true
    fi
  done
}

list_licenses() {
  dnf repoquery --installed --list "${1}" \
    | grep -Ei '^/usr/share/(doc|licenses)/.*(copying|licen[cs]e|readme|terms).*'
}

copy_licenses() {
  declare -A packages
  local package
  for library in "${libraries[@]}"; do
    package=$(dnf repoquery --installed --file "$(readlink -f -- "${library}")")
    [[ -z "${package}" ]] && continue
    packages["${package}"]="${library}"
  done

  for package in "${!packages[@]}"; do
    if ! list_licenses "${package}" >/dev/null; then
      for dependency in $(dnf repoquery --installed --requires --resolve "${package}"); do
        if [[ -z "${packages["${dependency}"]:-}" ]]; then
          # ignore dependencies with files in the excludelist
          for depfile in $(dnf repoquery --installed --list "${dependency}"); do
            [[ -n "${excludelist["$(basename "${depfile}")"]:-}" ]] && continue 2
          done
          packages["${dependency}"]="${packages["${package}"]}"
        fi
      done
    fi
  done

  dnf reinstall -y -v --setopt=timeout=5 --setopt=retries=3 --setopt=tsflags= "${!packages[@]}"

  for package in "${!packages[@]}"; do
    for file in $(list_licenses "${package}" || true); do
      install -vDm644 "${file}" "${OUTPUT}${file}"
    done
  done
}


find_libs
copy_licenses
