MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := run

# all targets are phony
.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

HOST=http://localhost
PORT=1313
BUILD_DIR=public
FTP_SERVER=lolcalhost
FTPS_SERVER=localhost
FTP_PORT=21
FTP_USERNAME=john
FTP_PASSWORD=doe
FTP_REMOTE_ROOT=dist

# .env
ifneq ("$(wildcard ./.env)","")
  include ./.env
endif

ifndef SLUG
  SLUG=""
endif

ifndef DATE
  DATE=""
endif

run: ## Run server
	@#hugo server --bind="0.0.0.0" --baseUrl="${HOST}" --port=${PORT} --buildDrafts --watch
	@npm run start

#run-without-draft: ## Run server without draft posts
#	@hugo server --watch

build: clean ## Build static html
	@#hugo
	@npm run build

clean: ## Clean old files
	@hugo --cleanDestinationDir
	@rm -fr ${BUILD_DIR}

create: ## Create post
	python -m app -s ${SLUG} -d ${DATE}
	@#echo "hugo new posts/<yyyy>/<mm>/<slug>.md"

fetch: ## Fetch content from Headless CMS
	@python -m app fetch

test: test-quiet ## Run test

test-quiet: ## Run test quiet
	@py.test -s -m "not (integration or slack)"

test-verbose: ## Run test verbose
	@py.test -s -v -m "not (integration or slack)"

test-integration: ## Run test (integration)
	@py.test -s -v -m "integration"

test-logger: ## Run test for logger
	@py.test -s -v -m "logger"

test-utils: ## Run test for utils
	@py.test -s -v -m "utils"

test-qiita: ## Run test for qiita
	@py.test -s -v -m "qiita"

test-datocms: ## Run test for datocms
	@py.test -s -v -m "datocms"

test-slack: ## Run test for slack
	@py.test -s -v -m "slack"

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
