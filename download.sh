#! /bin/bash

export LANG=en_US.UTF-8

APPHOME=$(cd -- "$(dirname -- ${0})" && pwd)
declare -r APPHOME

PKGHOME="${APPHOME}/docker/binary/"

DOCKER_URL="https://download.docker.com/linux/static/stable"
declare -r DOCKER_URL

COMPOSE_URL="https://github.com/docker/compose/releases/download"
declare -r COMPOSE_URL

DOCKER_VERSION="27.5.1"
COMPOSE_VERSION="v2.33.0"

# TODO: checksum
for arch in "x86_64" "aarch64"; do
  rm -rf "${PKGHOME:?}/${arch}"
  mkdir -p "${PKGHOME}/${arch}" && cd "${PKGHOME}/${arch}" || exit 1

  curl --output "docker.tgz" \
    "${DOCKER_URL}/${arch}/docker-${DOCKER_VERSION}.tgz" || exit 2

  curl --output "docker-compose" \
    "${COMPOSE_URL}/${COMPOSE_VERSION}/docker-compose-linux-${arch}" || exit 3
done