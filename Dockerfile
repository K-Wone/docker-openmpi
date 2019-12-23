# stage 1: build OpenMPI with GCC
ARG  GCC_VERSION=9.2.0
FROM gcc:${GCC_VERSION} AS builder

# define environment variables
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
FROM gcc:${GCC_VERSION}

# install mpi dependencies
RUN apt-get update && \
    apt-get install -y \
            openssh-server

# define environment variables
ARG OMPI_VERSION
ENV OMPI_VERSION=${OMPI_VERSION:-"4.0.0"}

ENV OMPI_PATH="/opt/openmpi/${OMPI_VERSION}"

# copy artifacts from stage 1
COPY --from=builder ${OMPI_PATH} ${OMPI_PATH}

# set environment variables for users
RUN set -eu; \
      { \
        echo "export PATH=\${OMPI_PATH}/bin:\$PATH"; \
        echo "export CPATH=\${OMPI_PATH}/include:\$CPATH"; \
        echo "export LIBRARY_PATH=\${OMPI_PATH}/lib:\$LIBRARY_PATH"; \
        echo "export LD_LIBRARY_PATH=\${OMPI_PATH}/lib:\$LD_LIBRARY_PATH"; \
      } > /etc/profile.d/openmpi-${OMPI_VERSION}.sh; \
      \
      chmod 644 /etc/profile.d/openmpi-${OMPI_VERSION}.sh

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
      groupadd -g ${GROUP_ID} ${GROUP_NAME}; \
      useradd -g ${GROUP_ID} -u ${USER_ID} -d ${USER_HOME} -m ${USER_NAME}; \
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
