#! /bin/bash

export LANG=en_US.UTF-8

APPHOME=$(cd -- "$(dirname -- ${0})" && pwd)
declare -r APPHOME

PKGHOME="${APPHOME}/docker/binary/"

DOCKER_URL="https://download.docker.com/linux/static/stable"
declare -r DOCKER_URL

VERSION="27.5.1"

for arch in "x86_64" "aarch64"; do
  rm -rf "${PKGHOME:?}/${arch}"
  mkdir -p "${PKGHOME}/${arch}" && \
  curl --silent --output "${PKGHOME}/${arch}/docker.tgz" "${DOCKER_URL}/${arch}/docker-${VERSION}.tgz"
done