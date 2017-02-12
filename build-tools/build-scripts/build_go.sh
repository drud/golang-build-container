#!/bin/sh
#
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -z "$EXTENDED_CHECKS" ]; then EXTENDED_CHECKS=true; fi

set -o errexit
set -o nounset
set -o pipefail

if [ -z "${PKG}" ]; then
    echo "PKG must be set"
    exit 1
fi
if [ -z "${OS}" ]; then
    echo "OS must be set"
    exit 1
fi
if [ -z "${VERSION}" ]; then
    echo "VERSION must be set"
    exit 1
fi

export CGO_ENABLED=0
export GOOS="${OS}"

TARGETS=$(for d in "$@"; do echo ./$d/...; done)

go install                                                     \
    -installsuffix "static"                                        \
    -ldflags "-X ${PKG}/pkg/version.VERSION=${VERSION}"            \
    $TARGETS

if [ "$EXTENDED_CHECKS" = "false" ]; then
	echo "EXTENDED_CHECKS=false so skipping gofmt/govet/vendorcheck"
else
	echo "EXTENDED_CHECKS=true so doing gofmt/govet/vendorcheck"
	echo -n "Checking gofmt: "
	ERRS=$(find "$@" -type f -name \*.go | xargs gofmt -l 2>&1 || true)
	if [ -n "${ERRS}" ]; then
		echo "FAIL - the following files need to be gofmt'ed:"
		for e in ${ERRS}; do
			echo "    $e"
		done
		echo
		exit 1
	fi
	echo "PASS"
	echo

	# go vet seems not to work cross-platform, so force GOOS
	echo -n "Checking go vet ${TARGETS}: "
	ERRS=$(GOOS=linux go vet ${TARGETS} 2>&1 || true)
	if [ -n "${ERRS}" ]; then
		echo "FAIL"
		echo "${ERRS}"
		echo
		exit 1
	fi
	echo "PASS"
	echo

	echo -n "Checking vendorcheck: "
	ERRS=$(vendorcheck -t 2>&1 || true)
	if [ -n "${ERRS}" ]; then
		echo "FAIL"
		echo "${ERRS}"
		echo
		exit 1
	fi
	echo "PASS"
	echo

	echo -n "Checking for unused vendors:"
	ERRS=$(govendor list +unused  2>&1 || true)
	if [ -n "${ERRS}" ]; then
		echo "FAIL"
		echo "${ERRS}"
		echo
		exit 1
	fi
	echo "PASS"
	echo
fi
