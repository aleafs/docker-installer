#!/bin/bash

set -o nounset

export LANG=en_US.UTF-8

APPHOME=$(cd -- "$(dirname -- ${0})" && pwd)
declare -r APPHOME

PKGHOME="${APPHOME}/pkg"
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
      chmod +x "${PKGHOME}/docker-compose" && \
      mkdir -p /usr/libexec/docker/cli-plugins && \
      mv -fv "${PKGHOME}/docker-compose" /usr/libexec/docker/cli-plugins/
    fi
}

function config_system_service() {
  cat > /usr/lib/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H unix://var/run/docker.sock
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
[Install]
WantedBy=multi-user.target
EOF
}

offline_install_docker
offline_install_compose

systemctl daemon-reload
systemctl --force enable docker.service
systemctl restart docker.service
