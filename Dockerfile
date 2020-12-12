FROM golang:1.15.6-buster
ENV GOLANGCI_LINT_VERSION v1.31.0
ENV GOTESTSUM_VERSION 0.4.2
ENV PACKR2_VERSION 2.6.0

# npm install crashes with default buster npm, use current stable instead
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update && apt-get install -y build-essential git curl nodejs python3-pip python3-dev

RUN npm install -g markdownlint-cli
RUN pip3 install mkdocs

RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin $GOLANGCI_LINT_VERSION

RUN curl -sSL "https://github.com/gotestyourself/gotestsum/releases/download/v$GOTESTSUM_VERSION/gotestsum_${GOTESTSUM_VERSION}_linux_amd64.tar.gz" | tar -xz -C /usr/local/bin gotestsum && chmod +x /usr/local/bin/gotestsum

RUN curl -sSL "https://github.com/gobuffalo/packr/releases/download/v${PACKR2_VERSION}/packr_${PACKR2_VERSION}_linux_amd64.tar.gz" | tar -xz -C /usr/local/bin packr2 && chmod +x /usr/local/bin/packr2

# discussion of various tools at
# http://blog.ralch.com/tutorial/golang-tools-inspection/
# https://dominik.honnef.co/posts/2014/12/go-tools/#goreturns

ENV GOTOOLSTOBUILD \
        github.com/FiloSottile/vendorcheck \
        github.com/GoASTScanner/gas \
        github.com/alecthomas/gocyclo \
        github.com/alecthomas/gometalinter \
        github.com/client9/misspell \
        golang.org/x/lint/golint \
        github.com/gordonklaus/ineffassign \
        github.com/jgautheron/goconst \
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
        golang.org/dl/gotip \
        honnef.co/go/tools/cmd/staticcheck \
        github.com/client9/misspell/cmd/misspell

RUN echo "GOTOOLSTOBUILD=$GOTOOLSTOBUILD"

RUN for item in $GOTOOLSTOBUILD; do \
	echo "Adding tool $item" && \
	go get -u $item; \
done

RUN gotip download
RUN cp -r ~/sdk /sdk

# /go/bin will be mounted on top, so get everything into /usr/local/bin
RUN cp -r /go/bin/* /usr/local/bin

ENV GOCACHE /go/.cache
