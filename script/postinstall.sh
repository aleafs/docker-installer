#! /bin/bash

export LANG=en_US.UTF-8

/usr/sbin/groupadd -r docker 2>/dev/null || :
/usr/sbin/usermod -aG docker $USER

/bin/systemctl daemon-reload
/bin/systemctl --force enable docker
/bin/systemctl restart docker
