VCS_REF := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
IMAGE_NAME := mrkaran/eks-gitops:1.2.1

build:
	@docker build \
	-t ${IMAGE_NAME} \
	--build-arg VCS_REF=${VCS_REF} \
	--build-arg BUILD_DATE=${BUILD_DATE} .

run:
	@docker run \
	-ti \
	-e CLUSTER_REGION=ap-south-1 \
	-e CLUSTER_NAME=test \
	${IMAGE_NAME} \
	/bin/sh

push:
	@docker push ${IMAGE_NAME}