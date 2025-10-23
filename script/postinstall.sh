#! /bin/bash

export LANG=en_US.UTF-8

if grep -w "net.ipv4.ip_forward" /etc/sysctl.conf > /dev/null; then
  sed -i.bak -e 's/net.ipv4.ip_forward\s*=\s*0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
else
  echo -e "\n# added by docker" >> /etc/sysctl.conf
  echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
fi

sysctl -p

/bin/systemctl daemon-reload
/bin/systemctl --force enable docker
/bin/systemctl restart docker
