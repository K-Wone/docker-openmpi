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

There are a bunch of build-time arguments you can use to build the GCC-OpenMPI image.

```bash
docker build \
        --build-arg GCC_VERSION="latest" \
        --build-arg OMPI_VMAJOR="4.0" \
        --build-arg OMPI_VMINOR="0" \
        --build-arg OMPI_OPTIONS="--enable-mpi-cxx" \
        -t my-repo/gompi .
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
