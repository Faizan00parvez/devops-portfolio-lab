SHELL := /bin/bash

APP_NAME ?= users-api
OWNER_LC ?= $(shell echo ${GITHUB_REPOSITORY_OWNER:-faizan00parvez} | tr '[:upper:]' '[:lower:]')
IMAGE_REGISTRY ?= ghcr.io/$(OWNER_LC)
IMAGE_TAG ?= $(shell git rev-parse --short HEAD)
IMAGE ?= $(IMAGE_REGISTRY)/$(APP_NAME):$(IMAGE_TAG)

KIND_CLUSTER ?= devops-portfolio
KIND_CONFIG ?= kind-cluster.yaml
KUBECONFIG ?= $(HOME)/.kube/config

.PHONY: bootstrap
bootstrap:
	ansible-playbook -i ansible/inventory ansible/site.yml

.PHONY: cluster
cluster:
	kind create cluster --name $(KIND_CLUSTER) --config $(KIND_CONFIG) --wait 90s || true

.PHONY: build
build:
	docker build -t $(IMAGE) -f docker/$(APP_NAME)/Dockerfile .

.PHONY: scan
scan:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-v $$PWD:/src aquasec/trivy:0.54.1 image --scanners vuln --exit-code 0 $(IMAGE)

.PHONY: push
push:
	docker push $(IMAGE)

.PHONY: deploy
deploy:
	helm upgrade --install $(APP_NAME) helm/$(APP_NAME) \
		--set image.repository=$(IMAGE_REGISTRY)/$(APP_NAME) \
		--set image.tag=$(IMAGE_TAG)

.PHONY: tf-init
tf-init:
	cd terraform && terraform init

.PHONY: tf-apply
tf-apply:
	cd terraform && terraform apply -auto-approve

.PHONY: tf-destroy
tf-destroy:
	cd terraform && terraform destroy -auto-approve

.PHONY: destroy
destroy: tf-destroy
	kind delete cluster --name $(KIND_CLUSTER) || true