FROM centos:7
# Install System requirements:
RUN <<SYS_REQ
    yum -y install wget
    yum -y groupinstall "Development Tools"
    yum -y install gcc openssl-devel bzip2-devel libffi-devel tk-devel
    yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
    yum -y install git
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
RUN /bin/bash <<MakePython
    cd /tmp/
    wget https://www.python.org/ftp/python/${python_version%a*}/Python-${python_version}.tgz
    tar xzf Python-${python_version}.tgz
    cd Python-${python_version}
    ./configure \
        --prefix=/opt/python/${python_version}/ --enable-optimizations \
        --with-lto --with-computed-gotos --with-system-ffi --enable-shared
    make -j$(nproc)
    make altinstall
    rm /tmp/Python-${python_version}.tgz
MakePython
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/python/${python_version}/lib/
ENV PATH=$PATH:/opt/python/${python_version}/bin/

# RUN yum-builddep -y python3
RUN <<othersysdep
    yum -y install ncurses-devel gdbm-devel readline-devel xz-devel sqlite-devel
othersysdep
# RUN /bin/bash <<tcl_tk
#     mkdir /opt/tcl && cd /opt/tcl
#     wget http://prdownloads.sourceforge.net/tcl/tcl8.6.13-src.tar.gz
#     tar xzf tcl8.6.13-src.tar.gz
#     cd tcl8.6.13/unix
#     ./configure --enable-threads --enable-shared --enable-symbols
#     make
#     make install
#     mkdir /opt/tk && cd /opt/tk
#     wget http://prdownloads.sourceforge.net/tcl/tk8.6.13-src.tar.gz
#     tar xzf tk8.6.13-src.tar.gz
#     cd tk8.6.13/unix
#     ./configure --with-tcl=/opt/tcl/tcl8.6.13/unix/
#     make
#     make install
# tcl_tk
ENV TCLTK_CFLAGS="-I/usr/include"
# ENV TCLTK_LIBS="-L/usr/local/lib -ltcl8.6 -ltk8.6"
ENV TCLTK_LIBS="-L/usr/lib64 -ltcl8.5 -ltk8.5"

RUN /bin/bash <<MakePython2
    cd /tmp/Python-${python_version}
    ./configure \
        --prefix=/opt/python/${python_version}/ --enable-optimizations \
        --with-lto --with-computed-gotos --with-system-ffi --enable-shared
    make -j$(nproc)
    make altinstall
MakePython2

# Install poetry
ARG poetry_version=1.4.2
RUN curl -sSL https://install.python-poetry.org | python${python_version%.*} - --version ${poetry_version}

ENV PATH="/root/.local/bin:$PATH"
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
CMD [ "/bin/bash" ]

#
#
#/tmp/Python-3.11.3/Modules/_tkinter.c:3424:1: note: file /tmp/Python-3.11.3/build/temp.linux-x86_64-3.11/tmp/Python-3.11.3/Modules/_tkinter.gcda not found, execution counts estimated
#  }
#  ^
# gcc -pthread -fPIC -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall -I/usr/include/openssl11 -I/usr/include/openssl11 -flto -fuse-linker-plugin -ffat-lto-objects -flto-partition=none -g -std=c11 -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wstrict-prototypes -Werror=implicit-function-declaration -fvisibility=hidden -fprofile-use -fprofile-correction -I./Include/internal -DWITH_APPINIT=1 -I/usr/include -I./Include -I/opt/python/3.11.3/include -I. -I/usr/local/include -I/tmp/Python-3.11.3/Include -I/tmp/Python-3.11.3 -c /tmp/Python-3.11.3/Modules/tkappinit.c -o build/temp.linux-x86_64-3.11/tmp/Python-3.11.3/Modules/tkappinit.o -Wno-strict-prototypes
# /tmp/Python-3.11.3/Modules/tkappinit.c: In function ‘Tcl_AppInit’:
# /tmp/Python-3.11.3/Modules/tkappinit.c:166:1: note: file /tmp/Python-3.11.3/build/temp.linux-x86_64-3.11/tmp/Python-3.11.3/Modules/tkappinit.gcda not found, execution counts estimated


# Failed tkinter installation tests:
# 415 tests OK.

# 19 tests skipped:
#     test_devpoll test_gdb test_idle test_ioctl test_kqueue
#     test_launcher test_msilib test_ossaudiodev test_startfile test_tcl
#     test_tix test_tk test_ttk_guionly test_ttk_textonly test_turtle
#     test_winconsoleio test_winreg test_winsound test_zipfile64

# Total duration: 16 min 8 sec
# Tests result: SUCCESS




# In python 3.10

#10 51.15 The following modules found by detect_modules() in setup.py, have been
#10 51.15 built by the Makefile instead, as configured by the Setup files:
#10 51.15 _abc                  pwd                   time               

# In python 3.11

# The necessary bits to build these optional modules were not found:
# _curses               _curses_panel         _dbm               
# _gdbm                 _lzma                 _tkinter           
# readline                                                       
# To find the necessary bits, look in setup.py in detect_modules() for the module's name.






# RUN yum-builddep -y python3

# bluez-libs-devel                x86_64       5.44-7.el7                         base           48 k
#  desktop-file-utils              x86_64       0.23-2.el7                         base           67 k
#  gdbm-devel                      x86_64       1.10-8.el7                         base           47 k
#  gmp-devel                       x86_64       1:6.0.0-15.el7                     base          181 k
#  libappstream-glib               x86_64       0.7.8-2.el7                        base          286 k
#  libtirpc-devel                  x86_64       0.2.4-0.16.el7                     base           91 k
#  ncurses-devel                   x86_64       5.9-14.20130511.el7_4              base          712 k
#  net-tools                       x86_64       2.0-0.25.20131004git.el7           base          306 k
#  python-rpm-macros               noarch       3-34.el7                           base          9.1 k
#  python3-pip                     noarch       9.0.3-8.el7                        base          1.6 M
#  python3-setuptools              noarch       39.2.0-10.el7                      base          629 k
#  readline-devel                  x86_64       6.2-11.el7                         base          139 k
#  sqlite-devel                    x86_64       3.7.17-8.el7_7.1                   base          104 k
#  systemtap-sdt-devel             x86_64       4.0-13.el7                         base           76 k
#  tix-devel                       x86_64       1:8.4.3-12.el7                     base          139 k
#  mesa-libGL-devel                x86_64       18.3.4-12.el7_9                    updates       164 k
#  xz-devel                        x86_64       5.2.2-2.el7_9                      updates        46 k
# Upgrading:
#  xz                              x86_64       5.2.2-2.el7_9                      updates       229 k
#  xz-libs                         x86_64       5.2.2-2.el7_9                      updates       103 k
# Installing dependencies:
#  bluez-libs                      x86_64       5.44-7.el7                         base           81 k
#  gdk-pixbuf2                     x86_64       2.36.12-3.el7                      base          570 k
#  gl-manpages                     noarch       1.1-7.20130122.el7                 base          994 k
#  glib-networking                 x86_64       2.56.1-1.el7                       base          145 k
#  gsettings-desktop-schemas       x86_64       3.28.0-3.el7                       base          606 k
#  hwdata                          x86_64       0.252-9.7.el7                      base          2.5 M
#  jasper-libs                     x86_64       1.900.1-33.el7                     base          150 k
#  jbigkit-libs                    x86_64       2.0-11.el7                         base           46 k
#  json-glib                       x86_64       1.4.2-2.el7                        base          134 k
#  libXdamage                      x86_64       1.1.4-4.1.el7                      base           20 k
#  libXdamage-devel                x86_64       1.1.4-4.1.el7                      base          9.7 k
#  libXext                         x86_64       1.3.3-3.el7                        base           39 k
#  libXext-devel                   x86_64       1.3.3-3.el7                        base           75 k
#  libXfixes                       x86_64       5.0.3-1.el7                        base           18 k
#  libXfixes-devel                 x86_64       5.0.3-1.el7                        base           13 k
#  libXxf86vm                      x86_64       1.1.4-1.el7                        base           18 k
#  libXxf86vm-devel                x86_64       1.1.4-1.el7                        base           18 k
#  libarchive                      x86_64       3.1.2-14.el7_7                     base          319 k
#  libdrm                          x86_64       2.4.97-2.el7                       base          151 k
#  libdrm-devel                    x86_64       2.4.97-2.el7                       base          143 k
#  libgcab1                        x86_64       0.7-4.el7_4                        base           66 k
#  libglvnd                        x86_64       1:1.0.1-0.8.git5baa1e5.el7         base           89 k
#  libglvnd-core-devel             x86_64       1:1.0.1-0.8.git5baa1e5.el7         base           20 k
#  libglvnd-devel                  x86_64       1:1.0.1-0.8.git5baa1e5.el7         base           11 k
#  libglvnd-egl                    x86_64       1:1.0.1-0.8.git5baa1e5.el7         base           44 k
#  libglvnd-gles                   x86_64       1:1.0.1-0.8.git5baa1e5.el7         base           34 k
#  libglvnd-glx                    x86_64       1:1.0.1-0.8.git5baa1e5.el7         base          125 k
#  libglvnd-opengl                 x86_64       1:1.0.1-0.8.git5baa1e5.el7         base           43 k
#  libjpeg-turbo                   x86_64       1.2.90-8.el7                       base          135 k
#  libpciaccess                    x86_64       0.14-1.el7                         base           26 k
#  libpipeline                     x86_64       1.2.3-3.el7                        base           53 k
#  libsoup                         x86_64       2.62.2-2.el7                       base          411 k
#  libtiff                         x86_64       4.0.3-35.el7                       base          172 k
#  libtirpc                        x86_64       0.2.4-0.16.el7                     base           89 k
#  libwayland-client               x86_64       1.15.0-1.el7                       base           33 k
#  libwayland-server               x86_64       1.15.0-1.el7                       base           39 k
#  libxshmfence                    x86_64       1.2-1.el7                          base          7.2 k
#  lzo                             x86_64       2.06-8.el7                         base           59 k
#  man-db                          x86_64       2.6.3-11.el7                       base          832 k
#  pyparsing                       noarch       1.5.6-9.el7                        base           94 k
#  tix                             x86_64       1:8.4.3-12.el7                     base          254 k
#  mesa-khr-devel                  x86_64       18.3.4-12.el7_9                    updates        20 k
#  mesa-libEGL                     x86_64       18.3.4-12.el7_9                    updates       110 k
#  mesa-libGL                      x86_64       18.3.4-12.el7_9                    updates       166 k
#  mesa-libgbm                     x86_64       18.3.4-12.el7_9                    updates        39 k
#  mesa-libglapi                   x86_64       18.3.4-12.el7_9                    updates        46 k
#  python3                         x86_64       3.6.8-18.el7                       updates        70 k
#  python3-libs                    x86_64       3.6.8-18.el7                       updates       6.9 M

