#! /bin/bash

export LANG=en_US.UTF-8

APPHOME=$(cd -- "$(dirname -- ${0})" && pwd)
declare -r APPHOME

PKGHOME="${APPHOME}/docker/binary/"

DOCKER_URL="https://download.docker.com/linux/static/stable"
declare -r DOCKER_URL

VERSION="27.5.1"

# TODO: checksum
for arch in "x86_64" "aarch64"; do
  rm -rf "${PKGHOME:?}/${arch}"
  mkdir -p "${PKGHOME}/${arch}" && cd "${PKGHOME}/${arch}" || exit 1

  curl --output "docker.tgz" \
    "${DOCKER_URL}/${arch}/docker-${VERSION}.tgz" || exit 2

  curl --output "docker-compose" \
    "https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-${arch}"
done