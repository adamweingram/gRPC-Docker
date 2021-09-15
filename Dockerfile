FROM grpc/cxx:1.10

RUN apt-get update

RUN apt-get install -y wget build-essential libssl-dev

# Build and install newer version of cmake

WORKDIR /tmp/

RUN wget https://github.com/Kitware/CMake/releases/download/v3.21.2/cmake-3.21.2.tar.gz

RUN tar zxvf cmake-3.21.2.tar.gz

WORKDIR /tmp/cmake-3.21.2

RUN ./bootstrap --prefix=/usr/local

RUN make

RUN make install

# Build gRPC

USER root

ENV HOME="/root"

RUN apt-get install -y git build-essential autoconf libtool pkg-config

RUN git clone --recurse-submodules -b v1.40.0 https://github.com/grpc/grpc.git /grpc

WORKDIR /grpc

RUN git submodule update --init

ENV MY_INSTALL_DIR="${HOME}/.local"

RUN mkdir -p $MY_INSTALL_DIR

ENV PATH="${MY_INSTALL_DIR}/bin:$PATH"

RUN mkdir -p cmake/build

#RUN pushd cmake/build
WORKDIR ./cmake/build

RUN cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TEST=OFF -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR ../..

RUN make -j

RUN make install

#RUN popd
WORKDIR /grpc

RUN mkdir -p ./third_party/abseil-cpp/cmake/build

#RUN pushd third_part/abseil-cpp/cmake/build
WORKDIR third_party/abseil-cpp/cmake/build

RUN cmake -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE ../..

RUN make -j 

RUN make install

#RUN popd
WORKDIR /grpc

# Return to normal access

WORKDIR /

# ENTRYPOINT ["/bin/bash"]
