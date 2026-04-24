#! /bin/bash

export LANG=en_US.UTF-8

if grep -w "net.ipv4.ip_forward" /etc/sysctl.conf > /dev/null; then
  sed -i.bak -e 's/net.ipv4.ip_forward\s*=\s*0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
else
  echo -e "\n# added by docker" >> /etc/sysctl.conf
  echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
fi

# kylin
# Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: container_linux.go:340: starting container process caused "permission denied": unknown
if [ -f /usr/local/bin/runc ]; then
  rm -fv /usr/local/bin/runc
fi

sysctl -p

/bin/systemctl daemon-reload
/bin/systemctl --force enable docker
/bin/systemctl restart docker
