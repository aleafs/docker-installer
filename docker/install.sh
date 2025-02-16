#!/bin/bash

export LANG=en_US.UTF-8

APPHOME=$(cd -- "$(dirname -- ${0})" && pwd)
declare -r APPHOME

PKGHOME="${APPHOME}/binary/$(uname -m)"
declare -r PKGHOME

function offline_install_docker() {
  if [ -f "${PKGHOME}/docker.tgz" ]; then
    tar -xzvf "${PKGHOME}/docker.tgz" && \
    chmod +x "${PKGHOME}/docker/*" && \
    mv -fv "${PKGHOME}/docker/*" /usr/bin/
  fi
}

function offline_install_compose() {
    if [ -f "${PKGHOME}/docker-compose" ]; then
      mkdir -p /usr/local/bin/docker-compose && \
      cp -fv "${PKGHOME}/docker-compose" /usr/local/bin/docker-compose && \
      chmod +x /usr/local/bin/docker-compose
    fi
}

echo ${PKGHOME}