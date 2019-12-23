FROM centos:centos8

WORKDIR /tmp

## install basic tools
RUN yum -y install yum-utils rpm-build\
                   which wget autoconf automake\
                   gcc gcc-c++ make\
                   openssh openssh-server openssh-clients bind-utils

## build and install OpenMPI
RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0-1.src.rpm; \
    rpm -ivh ./openmpi-4.0.0-1.src.rpm; \
    cd /root/rpmbuild/SPECS/; \
    rpmbuild -ba --define 'configure_options --prefix=/usr --enable-shared --enable-mpi-cxx' openmpi-4.0.0.spec; \
    cd /root/rpmbuild/RPMS/x86_64/; \
    yum -y install openmpi-4.0.0-1.el8.x86_64.rpm; \
    cd; \
    rm -rf /root/rpmbuild openmpi-4.0.0-1.src.rpm

## build and install HDF5 library
RUN wget -q -O hdf5.tgz https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/hdf5-1.10.5.tar.gz; \
    tar -zxf hdf5.tgz; \
    cd /tmp/hdf5-1.10.5; \
    ./autogen.sh; \
    ./configure --prefix=/usr --enable-cxx --enable-parallel --enable-unsupported; \
    make -j24; make install; \
    cd; \
    rm -rf /tmp/hdf5-1.10.5 /tmp/hdf5.tgz

## generate ssh keys
RUN ssh-keygen -f /root/.ssh/id_rsa -q -N ""; \
    mkdir -p ~/.ssh/ && chmod 700 ~/.ssh/
