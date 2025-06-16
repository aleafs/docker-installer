#! /bin/bash

export LANG=en_US.UTF-8

/usr/sbin/groupadd -r docker 2>/dev/null || :
/usr/sbin/usermod -aG docker root || :
