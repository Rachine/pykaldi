FROM ubuntu:16.04

ARG OPENFST_VERSION=1.6.5
ARG NUM_BUILD_CORES=4
ENV OPENFST_VERSION ${OPENFST_VERSION}
ENV NUM_BUILD_CORES ${NUM_BUILD_CORES}

# These are not installed from check_dependencies because the binaries are installed by python and libtool-bin
RUN apt-get update
RUN apt-get dist-upgrade -y

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:jonathonf/python-3.6

RUN apt-get update
RUN apt-get install -y sudo git apt-utils
RUN apt-get install -y python3.6 libtool python libtool-bin
RUN ln -s -f bash /bin/sh

# PyKaldi Pre-requisites

RUN apt-get install -y autoconf automake cmake curl g++ git graphviz \
    libatlas3-base libtool make pkg-config subversion unzip wget zlib1g-dev

RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install numpy pyparsing
RUN pip install ninja  # not required but strongly recommended


RUN git clone https://github.com/pykaldi/kaldi.git /kaldi --depth=1

WORKDIR tools/
RUN ./check_dependencies.sh  # checks if system dependencies are installed
RUN ./install_protobuf.sh    # installs both the C++ library and the Python package
RUN ./install_clif.sh        # installs both the C++ library and the Python package
RUN ./install_kaldi.sh       # installs the C++ library
WORKDIR ..
# RUN /kaldi/tools/extras/check_dependencies.sh | grep "sudo apt-get" | \
#             while read -r cmd; do \
#                   $cmd -y ; \
#             done
#
# RUN pushd /kaldi/tools; \
#             make OPENFST_VERSION=${OPENFST_VERSION} -j${NUM_BUILD_CORES}; \
#             popd
#
# RUN pushd /kaldi/src; ./configure --shared && make depend && make -j${NUM_BUILD_CORES}; popd

ENTRYPOINT ["bin/bash"]
