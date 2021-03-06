#===============================================================================
# Default User Options
#===============================================================================

# Build-time arguments
GCC_VERSION    ?= 9.2.0
OMPI_VERSION   ?= 4.0.0

# Spack variants
EXTRA_SPECS   ?= "target=skylake"
OMPI_OPTIONS  ?= ""

# Image name
DOCKER_IMAGE ?= leavesask/gompi
DOCKER_TAG   := $(OMPI_VERSION)

#===============================================================================
# Variables and objects
#===============================================================================

# Append a suffix to the tag if the version number of GCC
# is specified
DOCKER_TAG_FULL := $(DOCKER_TAG)
ifneq ($(GCC_VERSION),latest)
    DOCKER_TAG_FULL := $(DOCKER_TAG)-gcc-$(GCC_VERSION)
endif

BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_URL=$(shell git config --get remote.origin.url)

# Get the latest commit
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

#===============================================================================
# Targets to Build
#===============================================================================

.PHONY : docker_build docker_push output

default: build
build: docker_build output
release: docker_build docker_push output

docker_build:
	# Build Docker image
	docker build \
                 --build-arg GCC_VERSION=$(GCC_VERSION) \
                 --build-arg OMPI_VERSION=$(OMPI_VERSION) \
                 --build-arg OMPI_OPTIONS=$(OMPI_OPTIONS) \
                 --build-arg EXTRA_SPECS=$(EXTRA_SPECS) \
                 --build-arg BUILD_DATE=$(BUILD_DATE) \
                 --build-arg VCS_URL=$(VCS_URL) \
                 --build-arg VCS_REF=$(GIT_COMMIT) \
                 -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	# Tag image as latest
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

	# Tag image with the full tag
	if [[ "$(DOCKER_TAG)" != "$(DOCKER_TAG_FULL)" ]]; then \
      docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):$(DOCKER_TAG_FULL) && \
      docker push $(DOCKER_IMAGE):$(DOCKER_TAG_FULL); \
    fi

output:
	@echo Docker Image: $(DOCKER_IMAGE):$(DOCKER_TAG)
