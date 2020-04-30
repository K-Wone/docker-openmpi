# Build OpenMPI with latest spack
ARG SPACK_VERSION="0.14"
FROM spack/ubuntu-xenial:${SPACK_VERSION} AS builder

LABEL maintainer="Wang An <wangan.cs@gmail.com>"

USER root

ARG GCC_VERSION="9.2.0"
ENV GCC_VERSION=${GCC_VERSION}
ARG OMPI_VERSION="4.0.0"
ENV OMPI_VERSION=${OMPI_VERSION}
ARG OMPI_OPTIONS=""
ENV OMPI_OPTIONS=${OMPI_OPTIONS}

# install GCC
RUN set -eu; \
      \
      spack install gcc@${GCC_VERSION}; \
      spack load gcc@${GCC_VERSION}; \
      spack compiler add

# install OpenMPI
RUN set -eu; \
      \
      spack install openmpi@${OMPI_VERSION} %gcc@${GCC_VERSION} ${OMPI_OPTIONS}; \
      spack load -r openmpi@${OMPI_VERSION}

# install mpi runtime dependencies
RUN set -eu; \
      \
      apt-get update; \
      apt-get install -y \
              openssh-server \
              sudo

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

# initialize spack environment for all users
ENV SPACK_ROOT=/opt/spack
ENV PATH=${SPACK_ROOT}/bin:$PATH
RUN source ${SPACK_ROOT}/share/spack/setup-env.sh

# create the first user
RUN set -eu; \
      \
      groupadd -g ${GROUP_ID} ${GROUP_NAME}; \
      useradd  -m -G ${GROUP_NAME} -u ${USER_ID} ${USER_NAME}; \
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
ARG VCS_URL="https://github.com/alephpiece/docker-openmpi"
LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="OpenMPI docker image" \
      org.label-schema.description="An image for GCC and OpenMPI" \
      org.label-schema.license="MIT" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.schema-version="1.0"
