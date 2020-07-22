SEVERITIES = HIGH,CRITICAL

ifeq ($(TAG),)
TAG = dev
endif

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t rancher/image-build-crictl:$(TAG) .

.PHONY: image-push
image-push:
	docker push rancher/image-build-crictl:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/image-build-crictl:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/image-build-crictl:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/image-build-crictl:$(TAG) \
		$(shell docker image inspect rancher/image-build-crictl:$(TAG) | jq -r '.[] | .RepoDigests[0]')
