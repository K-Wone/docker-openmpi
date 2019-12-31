# stage 1: build OpenMPI with GCC
ARG GCC_VERSION=latest
FROM leavesask/gcc:${GCC_VERSION} AS builder

LABEL maintainer="Wang An <wangan.cs@gmail.com>"

USER root

# install basic buiding tools
RUN set -eu; \
      \
      sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' \
             /etc/apk/repositories; \
      apk add --no-cache \
              autoconf \
              automake \
              linux-headers \
              make \
              wget \
              which

# stage 1.1: download OpenMPI source
ARG OMPI_VMAJOR="4.0"
ENV OMPI_VMAJOR=${OMPI_VMAJOR}
ARG OMPI_VMINOR="0"
ENV OMPI_VMINOR=${OMPI_VMINOR}
ENV OMPI_VERSION="${OMPI_VMAJOR}.${OMPI_VMINOR}"
ENV OMPI_TARBALL="openmpi-${OMPI_VERSION}.tar.gz"

WORKDIR /tmp
RUN set -eux; \
      \
      # checksums are not provided due to the build-time arguments OMPI_VERSION
      wget "https://www.open-mpi.org/software/ompi/v${OMPI_VMAJOR}/downloads/${OMPI_TARBALL}"; \
      tar -xzf ${OMPI_TARBALL}

# stage 1.2: build and install OpenMPI
ARG OMPI_OPTIONS="--enable-mpi-cxx --enable-shared"
ENV OMPI_OPTIONS=${OMPI_OPTIONS}
ENV OMPI_PREFIX="/opt/openmpi/${OMPI_VERSION}"

WORKDIR /tmp/openmpi-${OMPI_VERSION}
RUN set -eux; \
      \
      ./configure \
                  --prefix=${OMPI_PREFIX} \
                  ${OMPI_OPTIONS} \
      ; \
      make -j "$(nproc)"; \
      make install; \
      \
      rm -rf openmpi-${OMPI_VERSION} ${OMPI_TARBALL}


# stage 2: build the runtime environment
ARG GCC_VERSION
FROM leavesask/gcc:${GCC_VERSION}

USER root

# install mpi dependencies
RUN set -eu; \
      \
      sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' \
             /etc/apk/repositories; \
      apk add --no-cache \
              linux-headers \
              openssh \
              sudo

# define environment variables
ARG OMPI_VMAJOR="4.0"
ARG OMPI_VMINOR="0"
ENV OMPI_VERSION="${OMPI_VMAJOR}.${OMPI_VMINOR}"
ENV OMPI_PATH="/opt/openmpi/${OMPI_VERSION}"

# copy artifacts from stage 1
COPY --from=builder ${OMPI_PATH} ${OMPI_PATH}

# set environment variables for users
ENV PATH="${OMPI_PATH}/bin:${PATH}"
ENV CPATH="${OMPI_PATH}/include:${CPATH}"
ENV LIBRARY_PATH="${OMPI_PATH}/lib:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${OMPI_PATH}/lib:${LD_LIBRARY_PATH}"

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

# generate ssh keys for root
RUN set -eu; \
      \
      ssh-keygen -f /root/.ssh/id_rsa -q -N ""; \
      mkdir -p ~/.ssh/ && chmod 700 ~/.ssh/

# generate ssh keys for the newly added user
USER ${USER_NAME}

WORKDIR ${USER_HOME}
RUN set -eu; \
      \
      ssh-keygen -f ${USER_HOME}/.ssh/id_rsa -q -N ""; \
      mkdir -p ~/.ssh/ && chmod 700 ~/.ssh/


# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL="https://github.com/K-Wone/docker-openmpi"
LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="OpenMPI docker image" \
      org.label-schema.description="A lightweight image for GCC and OpenMPI" \
      org.label-schema.license="MIT" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.schema-version="1.0"
