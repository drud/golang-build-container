FROM golang:1.17.2-bullseye AS golang-base
ENV GOLANGCI_LINT_VERSION v1.42.1
ENV GOTESTSUM_VERSION 1.7.0

# npm install crashes with default buster npm, use current stable instead
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update && apt-get install -y build-essential git curl nodejs python3-pip python3-dev

RUN npm install -g markdownlint-cli
RUN pip3 install mkdocs

RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin $GOLANGCI_LINT_VERSION

RUN curl -sSL "https://github.com/gotestyourself/gotestsum/releases/download/v$GOTESTSUM_VERSION/gotestsum_${GOTESTSUM_VERSION}_linux_amd64.tar.gz" | tar -xz -C /usr/local/bin gotestsum && chmod +x /usr/local/bin/gotestsum

# /go/bin will be mounted on top, so get everything into /usr/local/bin
RUN cp -r /go/bin/* /usr/local/bin

FROM scratch
ENV GOCACHE /go/.cache
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/local/go/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY --from=golang-base / /
