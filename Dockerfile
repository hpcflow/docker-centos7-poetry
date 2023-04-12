FROM centos:7
# Install System requirements:
RUN <<SYS_REQ
    yum -y install wget
    yum -y groupinstall "Development Tools"
    yum -y install gcc openssl-devel bzip2-devel libffi-devel tk-devel
SYS_REQ

# Install OpenSSL (1.1.1k):
RUN <<OpenSSL
    yum -y install epel-release
    yum -y install openssl11 openssl11-devel
OpenSSL
ENV CFLAGS="-I/usr/include/openssl11"
ENV LDFLAGS="-L/usr/lib64/openssl11 -lssl -lcrypto"

# Update GCC (needed for python >= 3.11):
RUN <<UpdateGCC
    yum -y install cvs
    yum -y install centos-release-scl
    yum -y install devtoolset-9-gcc-c++
UpdateGCC

# Install Python python_version from source:
ARG python_version=3.11.2
RUN <<MakePython
    cd /tmp/
    wget https://www.python.org/ftp/python/${python_version%a*}/Python-${python_version}.tgz
    tar xzf Python-${python_version}.tgz
    cd Python-${python_version}
    ./configure \
        --prefix=/opt/python/${python_version}/ --enable-optimizations \
        --with-lto --with-computed-gotos --with-system-ffi --enable-shared
    make
    make altinstall
    rm /tmp/Python-${python_version}.tgz
MakePython
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/python/${python_version}/lib/
ENV PATH=$PATH:/opt/python/${python_version}/bin/

# Install poetry
ARG poetry_version=1.4.2
RUN curl -sSL https://install.python-poetry.org | python${python_version%.*} - --version ${poetry_version}

# Install modern version of git
RUN <<ModernGit
    yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
    yum -y install git
ModernGit

ENV PATH="/root/.local/bin:$PATH"
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
CMD [ "/bin/bash" ]
