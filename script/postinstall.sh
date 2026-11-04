#! /bin/bash

export LANG=en_US.UTF-8

cat << EOF > /etc/sysctl.d/99-docker.conf
# added by docker
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.all.accept_ra = 2
EOF

# kylin
# Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: container_linux.go:340: starting container process caused "permission denied": unknown
if [ -f /usr/local/bin/runc ]; then
  rm -fv /usr/local/bin/runc
fi

sysctl -p

/bin/systemctl daemon-reload
/bin/systemctl --force enable docker
/bin/systemctl restart docker
