[![Layers](https://images.microbadger.com/badges/image/leavesask/gompi.svg)](https://microbadger.com/images/leavesask/gompi)
[![Version](https://images.microbadger.com/badges/version/leavesask/gompi.svg)](https://hub.docker.com/repository/docker/leavesask/gompi)
[![Commit](https://images.microbadger.com/badges/commit/leavesask/gompi.svg)](https://github.com/K-Wone/docker-openmpi)
[![License](https://images.microbadger.com/badges/license/leavesask/gompi.svg)](https://github.com/K-Wone/docker-openmpi)
[![Docker Pulls](https://img.shields.io/docker/pulls/leavesask/gompi?color=informational)](https://hub.docker.com/repository/docker/leavesask/gompi)
[![Automated Build](https://img.shields.io/docker/automated/leavesask/gompi)](https://hub.docker.com/repository/docker/leavesask/gompi)

# Supported tags

- `4.0.0`, `4.0.0-gcc-9.2.0`, `4.0.0-gcc-5.5.0`
- `3.1.5`, `3.1.5-gcc-9.2.0`, `3.1.5-gcc-5.5.0`

# How to use

1. [Install docker engine](https://docs.docker.com/install/)

2. Pull the image
  ```bash
  docker pull leavesask/gompi:<tag>
  ```

3. Run the image interactively
  ```bash
  docker run -it --rm leavesask/gompi:<tag>
  ```

# How to build

The base image is [spack/ubuntu-xenial](https://hub.docker.com/r/spack/ubuntu-xenial).

## make

There are a bunch of build-time arguments you can use to build the GCC-OpenMPI image.

It is highly recommended that you build the image with `make`.

```bash
# Build an image for OpenMPI 4.0.0
make OMPI_VERSION="4.0.0" GCC_VERSION="9.2.0"

# Build and publish the image
make release OMPI_VERSION="4.0.0"
```

Check `Makefile` for more options.

## docker build

As an alternative, you can build the image with `docker build` command.

```bash
docker build \
        --build-arg GCC_VERSION="latest" \
        --build-arg OMPI_VERSION="4.0.0" \
        --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
        --build-arg VCS_REF=`git rev-parse --short HEAD` \
        -t my-repo/gompi:latest .
```

Arguments and their defaults are listed below.

- `GCC_VERSION`: The version of GCC supported by spack (defaults to `9.2.0`)

- `OMPI_VERSION`: The version of OpenMPI supported by spack (defaults to `4.0.0`)

- `OMPI_OPTIONS`: Spack variants (defaults to none)

- `GROUP_NAME`: User group (defaults to `mpi`)
- `USER_NAME`: User name (defaults to `one`)
  - This is the default user when the image is started.
