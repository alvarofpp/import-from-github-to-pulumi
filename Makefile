# Variables
DOCKER_IMAGE=alvarofpp/import-from-github-to-pulumi
ROOT=$(shell pwd)
DIR=image/
UID=$(shell id -u)
GID=$(shell id -g)

## Lint
DOCKER_IMAGE_LINTER=alvarofpp/linter:latest
LINT_COMMIT_TARGET_BRANCH=origin/main

# Commands
.PHONY: install-hooks
install-hooks:
	git config core.hooksPath .githooks

.PHONY: build
build: install-hooks
	@docker build ${DIR} \
	    --build-arg USER_UID=${UID} \
	    --build-arg GROUP_ID=${GID} \
	    -t ${DOCKER_IMAGE}

.PHONY: build-no-cache
build-no-cache: install-hooks
	@docker build ${DIR} \
	    --build-arg USER_UID=${UID} \
	    --build-arg GROUP_ID=${GID} \
	    -t ${DOCKER_IMAGE} --no-cache

.PHONY: lint
lint:
	@docker pull ${DOCKER_IMAGE_LINTER}
	@docker run --rm -v ${ROOT}:/app ${DOCKER_IMAGE_LINTER} " \
		lint-commit ${LINT_COMMIT_TARGET_BRANCH} \
		&& lint-markdown \
		&& lint-dockerfile \
		&& lint-yaml \
		&& lint-shell-script"

.PHONY: shell
shell:
	@docker run --rm -it \
	    --user ${UID}:${GID} \
	    --volume ./logs:/tmp/logs \
	    --volume ./resources:/opt/resources \
	    --volume ./image/commands:/opt/commands \
	    --volume ./image/templates:/opt/templates \
	    --volume ./:/home/infra \
	    --env GITHUB_ACCESS_TOKEN="${GITHUB_ACCESS_TOKEN}" \
	    --env GITHUB_ORG="${GITHUB_ORG}" \
	    --env GITHUB_USER="${GITHUB_USER}" \
	    ${DOCKER_IMAGE} sudo -E bash

.PHONY: import-my-repos
import-my-repos:
	@docker run --rm \
	    --user ${UID}:${GID} \
	    --volume ./resources:/opt/resources \
	    --volume ./logs:/tmp/logs \
	    --env GITHUB_ACCESS_TOKEN="${GITHUB_ACCESS_TOKEN}" \
	    --env GITHUB_USER="${GITHUB_USER}" \
	    ${DOCKER_IMAGE} import-repositories-to-pulumi

.PHONY: import-org
import-org:
	@docker run --rm \
	    --user ${UID}:${GID} \
	    --volume ./resources:/opt/resources \
	    --volume ./logs:/tmp/logs \
	    --env GITHUB_ACCESS_TOKEN="${GITHUB_ACCESS_TOKEN}" \
	    --env GITHUB_ORG="${GITHUB_ORG}" \
	    ${DOCKER_IMAGE} import-org-to-pulumi
