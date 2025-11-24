# Makefile to build, tag (with git commit hash), push and deploy with kamal
# Usage:
#   make build-deploy            # uses default IMAGE_REPO
#   make build-deploy IMAGE_REPO=youruser/yourrepo

IMAGE_REPO ?= sofc-t/kamal-first
COMMIT := $(shell git rev-parse --short HEAD)
TEMPLATE := config/deploy.dev.yml.template
OUT := config/deploy.dev.generated.yml

.PHONY: build push generate deploy build-deploy

build:
	@echo "Building image $(IMAGE_REPO):$(COMMIT)"
	docker build -t $(IMAGE_REPO):$(COMMIT) .

push:
	@echo "Pushing image $(IMAGE_REPO):$(COMMIT)"
	docker push $(IMAGE_REPO):$(COMMIT)

generate:
	@if [ ! -f "$(TEMPLATE)" ]; then \
		echo "Template $(TEMPLATE) not found"; exit 1; \
	fi
	@echo "Generating deploy YAML $(OUT) from template"
	sed "s/{{COMMIT}}/$(COMMIT)/g" $(TEMPLATE) > $(OUT)

deploy: generate
	@echo "Deploying using $(OUT)"
	kamal deploy --config $(OUT) -e dev

build-deploy: build push deploy
	@echo "Done: deployed $(IMAGE_REPO):$(COMMIT)"
