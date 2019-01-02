FROM golang:1.11.4-alpine
ENV GOLANGCI_LINT_VERSION v1.12.5
ENV GOTESTSUM_VERSION 0.3.2

RUN apk update && apk add git bash build-base curl

RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin $GOLANGCI_LINT_VERSION

RUN curl -sSL "https://github.com/gotestyourself/gotestsum/releases/download/v$GOTESTSUM_VERSION/gotestsum_${GOTESTSUM_VERSION}_linux_amd64.tar.gz" | tar -xz -C /usr/local/bin gotestsum && chmod +x /usr/local/bin/gotestsum

# discussion of various tools at
# http://blog.ralch.com/tutorial/golang-tools-inspection/
# https://dominik.honnef.co/posts/2014/12/go-tools/#goreturns

ENV GOTOOLSTOBUILD \
        github.com/FiloSottile/vendorcheck \
        github.com/GoASTScanner/gas \
        github.com/alecthomas/gocyclo \
        github.com/alecthomas/gometalinter \
        github.com/client9/misspell \
        github.com/golang/lint/golint \
        github.com/gordonklaus/ineffassign \
        github.com/jgautheron/goconst \
        github.com/golang/dep/cmd/dep \
        github.com/kisielk/errcheck \
        github.com/mdempsky/unconvert \
        github.com/mibk/dupl \
        mvdan.cc/interfacer \
        mvdan.cc/unparam \
        github.com/opennota/check/cmd/aligncheck \
        github.com/opennota/check/cmd/structcheck \
        github.com/opennota/check/cmd/varcheck \
        github.com/stretchr/testify \
        github.com/stripe/safesql \
        github.com/tsenart/deadcode \
        github.com/walle/lll \
        golang.org/x/tools/cmd/goimports \
        honnef.co/go/tools/cmd/staticcheck \
        github.com/client9/misspell/cmd/misspell

RUN echo "GOTOOLSTOBUILD=$GOTOOLSTOBUILD"

RUN for item in $GOTOOLSTOBUILD; do \
	echo "Adding tool $item" && \
	go get -u $item; \
done

# /go/bin will be mounted on top, so get everything into /usr/local/bin
RUN cp -r /go/bin/* /usr/local/bin

ENV GOCACHE /go/.cache
