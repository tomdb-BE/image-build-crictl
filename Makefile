UNAME_M = $(shell uname -m)
ARCH=
ifeq ($(UNAME_M), x86_64)
	ARCH=amd64
else
	ARCH=$(UNAME_M)
endif

SEVERITIES = HIGH,CRITICAL

ifeq ($(TAG),)
TAG = dev
endif

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t rancher/hardened-crictl:$(TAG) .

.PHONY: image-push
image-push:
	docker push rancher/hardened-crictl:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/hardened-crictl:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/hardened-crictl:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/hardened-crictl:$(TAG) \
		$(shell docker image inspect rancher/hardened-crictl:$(TAG) | jq -r '.[] | .RepoDigests[0]')
