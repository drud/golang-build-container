#!/bin/bash

set -eu -o pipefail
containerspec=$1

docker run --rm "${containerspec}" go version
