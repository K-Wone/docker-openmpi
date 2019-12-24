# stage 1: build OpenMPI with GCC
ARG BASE_VERSION=latest
FROM alpine:${BASE_VERSION} AS builder

# install basic buiding tools
RUN set -eu; \
      \
      sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' \
             /etc/apk/repositories; \
      apk add --no-cache \
              autoconf \
              automake \
              build-base \
              linux-headers \
              make \
              wget \
              which

# define environment variables for building OpenMPI
ARG OMPI_VERSION_MAJOR_MINOR
ENV OMPI_VERSION_MAJOR_MINOR=${OMPI_VERSION_MAJOR_MINOR:-"4.0"}
ARG OMPI_VERSION
ENV OMPI_VERSION=${OMPI_VERSION:-"4.0.0"}
ARG OMPI_PREFIX
ENV OMPI_PREFIX=${OMPI_PREFIX:-"/opt/openmpi/${OMPI_VERSION}"}
ARG OMPI_OPTIONS
ENV OMPI_OPTIONS=${OMPI_OPTIONS:-"--enable-mpi-cxx --enable-shared"}

ENV OMPI_TARBALL="openmpi-${OMPI_VERSION}.tar.gz"

# build and install OpenMPI
WORKDIR /tmp
RUN set -eux; \
      \
      # checksums are not provided due to the build-time arguments OMPI_VERSION
      wget "https://www.open-mpi.org/software/ompi/v${OMPI_VERSION_MAJOR_MINOR}/downloads/${OMPI_TARBALL}"; \
      tar -xzf ${OMPI_TARBALL}; \
      \
      cd openmpi-${OMPI_VERSION}; \
      ./configure \
                  --prefix=${OMPI_PREFIX} \
                  ${OMPI_OPTIONS} \
      ; \
      make -j "$(nproc)"; \
      make install; \
      \
      rm -rf openmpi-${OMPI_VERSION} ${OMPI_TARBALL}


# stage 2: build the runtime environment
ARG BASE_VERSION
FROM alpine:${BASE_VERSION}

# install mpi dependencies
RUN set -eu; \
      \
      sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' \
             /etc/apk/repositories; \
      apk add --no-cache \
              build-base \
              openssh

# define environment variables
ARG OMPI_VERSION
ENV OMPI_VERSION=${OMPI_VERSION:-"4.0.0"}

ENV OMPI_PATH="/opt/openmpi/${OMPI_VERSION}"

# copy artifacts from stage 1
COPY --from=builder ${OMPI_PATH} ${OMPI_PATH}

# set environment variables for users
RUN set -eu; \
      mkdir -p /usr/local/bin \
               /usr/local/lib \
               /usr/local/include \
      ; \
      ln -s ${OMPI_PATH}/bin/* /usr/local/bin; \
      ln -s ${OMPI_PATH}/lib/* /usr/local/lib; \
      ln -s ${OMPI_PATH}/include/* /usr/local/include

# define environment variables
ARG GROUP_NAME
ENV GROUP_NAME=${GROUP_NAME:-mpi}
ARG GROUP_ID
ENV GROUP_ID=${GROUP_ID:-1000}
ARG USER_NAME
ENV USER_NAME=${USER_NAME:-one}
ARG USER_ID
ENV USER_ID=${USER_ID:-1000}

ENV USER_HOME="/home/${USER_NAME}"

# create the first user
RUN set -eu; \
      \
      addgroup -g ${GROUP_ID} ${GROUP_NAME}; \
      adduser  -D -G ${GROUP_NAME} -u ${USER_ID} -h ${USER_HOME} ${USER_NAME}; \
      \
      echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# transfer control to the newly added user
WORKDIR ${USER_HOME}
USER ${USER_NAME}

# generate ssh keys
RUN set -eu; \
      \
      ssh-keygen -f ${USER_HOME}/.ssh/id_rsa -q -N ""; \
      mkdir -p ~/.ssh/ && chmod 700 ~/.ssh/
