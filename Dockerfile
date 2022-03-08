FROM centos:7
RUN \
    # Install Python 3.9.10 from source:
    yum install -y dnf \
    && dnf -y install wget \
    && dnf -y groupinstall "Development Tools" \
    && dnf -y install gcc openssl-devel bzip2-devel libffi-devel \
    && cd /tmp/ \
    && wget https://www.python.org/ftp/python/3.9.10/Python-3.9.10.tgz \
    && tar xzf Python-3.9.10.tgz \
    && cd Python-3.9.10 \
    && ./configure --prefix=/opt/python/3.9.10/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi --enable-shared --enable-unicode=ucs4\
    && make \
    && make altinstall \
    && rm /tmp/Python-3.9.10.tgz
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/python/3.9.10/lib/
ENV PATH=$PATH:/opt/python/3.9.10/bin/ 
RUN \
    # Install poetry
    curl -sSL https://install.python-poetry.org | python3.9
RUN \ 
    # Install modern version of git
    yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm \
    && yum -y install git
ENV PATH="/root/.local/bin:$PATH"
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
CMD [ "/bin/bash" ]
