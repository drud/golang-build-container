#!/bin/bash

set -eu -o pipefail
containerspec=$1

docker run --rm "${containerspec}" go version
docker run --rm "${containerspec}" go1.16 version
