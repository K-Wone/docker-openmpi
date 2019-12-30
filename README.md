[![layers](https://images.microbadger.com/badges/image/leavesask/gompi.svg)](https://microbadger.com/images/leavesask/gompi "Get your own image badge on microbadger.com")
[![version](https://images.microbadger.com/badges/version/leavesask/gompi.svg)](https://microbadger.com/images/leavesask/gompi)

# Supported tags

- `4.0.0`
- `3.1.5`

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

## make

There are a bunch of build-time arguments you can use to build the GCC-OpenMPI image.

It is hightly recommended that you build the image with `make`.

```bash
# Build an image for OpenMPI 4.0.0
make OMPI_VMAJOR="4.0" OMPI_VMINOR="0"

# Build and publish the image
make release OMPI_VMAJOR="4.0" OMPI_VMINOR="0"
```

Check `Makefile` for more options.

## docker build

As an alternative, you can build the image with `docker build` command.

```bash
docker build \
        --build-arg GCC_VERSION="latest" \
        --build-arg OMPI_VMAJOR="4.0" \
        --build-arg OMPI_VMINOR="0" \
        --build-arg OMPI_OPTIONS="--enable-mpi-cxx" \
        --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
        --build-arg VCS_REF=`git rev-parse --short HEAD` \
        -t my-repo/gompi:latest .
```

Arguments and their defaults are listed below.

- `GCC_VERSION`: tag (default=`latest`)
  - This is the tag of the base image for all of the stages.
  - The docker repository defaults to `leavesask/gcc`.

- `OMPI_VMAJOR`: X.X (default=`4.0`)

- `OMPI_VMINOR`: X (default=`0`)

- `OMPI_OPTIONS`: option\[=value\] (default=`--enable-mpi-cxx --enable-shared`)
  - Options needed to configure the installation.
  - The default installation path is `/opt/openmpi/${OMPI_VERSION}` so that option `--prefix` is unnecessary.

- `GROUP_NAME`: value (default=`mpi`)
- `USER_NAME`: value (default=`one`)
  - A user to be added.
  - This is the default user when the image is started.
