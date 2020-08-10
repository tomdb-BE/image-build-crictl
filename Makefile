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
	docker build --build-arg TAG=$(TAG) -t rancher/image-build-crictl:$(TAG)-$(ARCH) .

.PHONY: image-push
image-push:
	docker push rancher/image-build-crictl:$(TAG)-$(ARCH) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/image-build-crictl:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/image-build-crictl:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/image-build-crictl:$(TAG)-$(ARCH) \
		$(shell docker image inspect rancher/image-build-crictl:$(TAG)-$(ARCH) | jq -r '.[] | .RepoDigests[0]')
