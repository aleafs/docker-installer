#!/bin/bash

export LANG=en_US.UTF-8

APPHOME=$(cd -- "$(dirname -- ${0})" && pwd)
declare -r APPHOME

OFFLINE_PATH="${APPHOME}/binary/$(uname -m)"
declare -r OFFLINE_PATH



echo ${OFFLINE_PATH}