#! /bin/bash

export LANG=en_US.UTF-8

if [ $1 -eq 0 ]; then
  # Package removal, not upgrade
  /bin/systemctl disable docker >/dev/null 2>&1 || :
  /bin/systemctl stop docker >/dev/null 2>&1 || :
  /bin/systemctl reset-failed docker >/dev/null 2>&1 || :
fi
