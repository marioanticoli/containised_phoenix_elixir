# Makefile for car-pooling-challenge
# vim: set ft=make ts=8 noet
# Copyright Cabify.com
# Licence MIT

# Variables
# UNAME		:= $(shell uname -s)

PORT=9091
PHX_SERVER=true
POOL_SIZE=5
CONTAINER_NAME=cabify

.EXPORT_ALL_VARIABLES:

# this is godly
# https://news.ycombinator.com/item?id=11939200
.PHONY: help
help:	### this screen. Keep it first target to be default
ifeq ($(UNAME), Linux)
	@grep -P '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
else
	@# this is not tested, but prepared in advance for you, Mac drivers
	@awk -F ':.*###' '$$0 ~ FS {printf "%15s%s\n", $$1 ":", $$2}' \
		$(MAKEFILE_LIST) | grep -v '@awk' | sort
endif

# Targets
#
.PHONY: debug
debug:	### Debug Makefile itself
	@echo $(UNAME)

.PHONY: clean
clean:
	@docker stop ${CONTAINER_NAME} || true
	@docker rm ${CONTAINER_NAME} || true

.PHONY: build
build:
	@docker image build -t elixir/cabify .

.PHONY: dockerize
dockerize: build clean
	@docker container run -dp ${PORT}:${PORT} \
		-e PHX_SERVER=${PHX_SERVER} -e POOL_SIZE=${POOL_SIZE} -e PORT=${PORT} \
		--name ${CONTAINER_NAME} elixir/${CONTAINER_NAME}
