#! /bin/bash

export LANG=en_US.UTF-8

/bin/systemctl daemon-reload
/bin/systemctl --force enable docker
/bin/systemctl restart docker
