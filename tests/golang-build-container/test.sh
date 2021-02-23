#!/bin/bash

set -eu -o pipefail
containerspec=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker run -u $(id -u):$(id -g) -v ${DIR}:/source --rm "${containerspec}" bash -c "cd /source && go run main.go"
