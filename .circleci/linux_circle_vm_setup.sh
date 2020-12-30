#!/usr/bin/env bash

set -o errexit
set -x

if [ ! -z "${DOCKERHUB_PULL_USERNAME:-}" ]; then
  set +x
  echo "${DOCKERHUB_PULL_PASSWORD}" | docker login --username "${DOCKERHUB_PULL_USERNAME}" --password-stdin
  set -x
fi

sudo apt-get update -qq
sudo apt-get install -qq coreutils zip jq expect nfs-kernel-server build-essential curl git libcurl4-gnutls-dev


