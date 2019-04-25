VERSION := $(shell git describe --always --dirty --tags 2>/dev/null || echo "undefined")
IMG ?= quay.io/pusher/k8s-spot-termination-handler

RED := \033[31m
GREEN := \033[32m
NC := \033[0m

.PHONY: all
all: lint

.PHONY: lint
lint:
	@ echo "$(GREEN)Linting code$(NC)"
	@ if [ ! $$(which flake8) ]; then echo "$(RED)flake8 not found - please install 'python -m pip install flake8'$(NC)"; exit 1; fi
	flake8 docker-entrypoint.py --max-line-length=120 --max-complexity=8
	@ if [ ! $$(which pylint) ]; then echo "$(RED)pylint not found - please install 'python -m pip install pylint'$(NC)"; exit 1; fi
	pylint docker-entrypoint.py --max-line-length=120
	@ echo

.PHONY: docker-build
docker-build:
	docker build --build-arg VERSION=${VERSION}  . -t ${IMG}:${VERSION}
	@echo "$(GREEN)Built $(IMG):$(VERSION)$(NC)"

TAGS ?= latest
.PHONY: docker-tag
docker-tag: docker-build
	@IFS=","; tags=${TAGS}; for tag in $${tags}; do docker tag ${IMG}:${VERSION} ${IMG}:$${tag}; echo "$(GREEN)Tagged $(IMG):$(VERSION) as $${tag}$(NC)"; done

PUSH_TAGS ?= ${VERSION}, latest
.PHONY: docker-push
docker-push: docker-build docker-tag
	@IFS=","; tags=${PUSH_TAGS}; for tag in $${tags}; do docker push ${IMG}:$${tag}; echo "$(GREEN)Pushed $(IMG):$${tag}$(NC)"; done

TAGS ?= latest
.PHONY: docker-clean
docker-clean:
	@IFS=","; tags=${TAGS}; for tag in $${tags}; do docker rmi -f ${IMG}:${VERSION} ${IMG}:$${tag}; done
