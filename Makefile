VCS_REF := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
IMAGE_NAME := mrkaran/eks-gitops
CURRENT_BUILD_TAG := 1.3.0
LATEST_TAG:= latest

build:
	docker build \
	-t ${IMAGE_NAME}:${CURRENT_BUILD_TAG} \
	-t ${IMAGE_NAME}:${LATEST_TAG} \
	--build-arg VCS_REF=${VCS_REF} \
	--build-arg BUILD_DATE=${BUILD_DATE} .

run:
	docker run \
	-ti \
	-e CLUSTER_REGION=ap-south-1 \
	-e CLUSTER_NAME=test \
	${IMAGE_NAME}:${LATEST_TAG} \
	/bin/sh

push:
	docker push ${IMAGE_NAME}:${CURRENT_BUILD_TAG}
	docker push ${IMAGE_NAME}:${LATEST_TAG}