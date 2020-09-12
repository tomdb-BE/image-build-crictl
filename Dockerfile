ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.14.2

FROM ${UBI_IMAGE} as ubi

FROM ${GO_IMAGE} as builder
ARG TAG="" 
RUN apt update     && \ 
    apt upgrade -y && \ 
    apt install -y ca-certificates git
RUN git clone --depth=1 https://github.com/kubernetes-sigs/cri-tools.git
RUN cd cri-tools                       && \
    git fetch --all --tags --prune     && \
    git checkout tags/${TAG} -b ${TAG} && \
    go build -o _output/crictl -ldflags '-X github.com/kubernetes-sigs/cri-tools/pkg/version.Version=${TAG}' -tags '$(BUILDTAGS)' github.com/kubernetes-sigs/cri-tools/cmd/crictl

FROM ubi
RUN microdnf update -y && \ 
    rm -rf /var/cache/yum

COPY --from=builder /go/cri-tools/_output/crictl /usr/local/bin
