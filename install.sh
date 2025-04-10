#!/bin/bash

set -o nounset

export LANG=en_US.UTF-8

APPHOME=$(cd -- "$(dirname -- ${0})" && pwd)
declare -r APPHOME

function offline_install_docker() {
  if [ -f "${APPHOME}/docker.tgz" ]; then
    rm -fr /tmp/docker 2>/dev/null
    tar -xzf "${APPHOME}/docker.tgz" -C /tmp && \
    chmod +x "/tmp/docker/"* && \
    mv -fv "/tmp/docker/"* /usr/bin/ && rm -fr "/tmp/docker"
  fi
}

function offline_install_compose() {
    if [ -f "${APPHOME}/docker-compose" ]; then
      chmod +x "${APPHOME}/docker-compose" && \
      mkdir -p /usr/libexec/docker/cli-plugins && \
      mv -fv "${APPHOME}/docker-compose" /usr/libexec/docker/cli-plugins/
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
ExecReload=/bin/kill -s HUP \$MAINPID
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

function config_docker_root_dir() {
  threshold=209715200
  available=$(df /var/lib | awk '{print $4}' | tail -n1)
  if [ "${available}" -ge ${threshold} ]; then
    # greater than 200GB
    return
  fi

  target=$(df | grep -vE '^Filesystem|tmpfs|cdrom' | sort -nr -k4 | awk '{print $6}' | head -n1)
  if [ ${#target} -le 1 ]; then
    return
  fi

  target="${target}/docker-data"
  if [ -e "${target}" ]; then
    return
  fi

  echo "Will set docker root dir to \"${target}\", Yes/No?"
  read -t 30 -r prompt
  case "${prompt-No}" in
    Yes|Y|yes)
    ;;
  *)
    echo "Cancelled!"
    return
    ;;
  esac

  suffix=$(date +"%Y%m%d")
  config="/etc/docker/daemon.json"
  if [ -f "${config}" ]; then
    mv -fv "${config}" "${config}.${suffix}"
  fi

  prefix=$(dirname -- "${config}")
  mkdir -p "${prefix}" && cat > "${config}" << EOF
{
  "data-root": "${target}"
}
EOF
}

offline_install_docker
offline_install_compose
config_docker_root_dir
config_system_service

systemctl daemon-reload
systemctl --force enable docker.service
systemctl restart docker.service
