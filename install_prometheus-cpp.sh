#!/bin/bash

yum -y install gcc gcc-c++ make curl curl-devel openssl openssl-devel git rpm-build

#
# install cmake
#
cmake_version=3.19.3
wget https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}.tar.gz
tar -zxf cmake-${cmake_version}.tar.gz
cd cmake-${cmake_version}
./bootstrap
gmake
gmake install
cmake --version

#
# install prometheus-cpp
#
cd ..

git clone https://github.com/jupp0r/prometheus-cpp.git
cd prometheus-cpp
# fetch third-party dependencies
git submodule init
git submodule update

mkdir _build
cd _build

# run cmake
cmake .. -DBUILD_SHARED_LIBS=ON # or OFF for static libraries
# build
make -j 4
# run tests
ctest -V
# install the libraries and headers
mkdir -p deploy
make DESTDIR=`pwd`/deploy install

#
# package
#
cd ..
# fetch third-party dependencies
git submodule update --init
# run cmake
cmake -B_build -DCPACK_GENERATOR=DEB -DBUILD_SHARED_LIBS=ON # or OFF for static libraries
# build and package
cmake --build _build --target package --parallel 1

# fetch third-party dependencies
git submodule update --init
# run cmake
cmake -B_build -DCPACK_GENERATOR=RPM -DBUILD_SHARED_LIBS=ON # or OFF for static libraries
# build and package
cmake --build _build --target package --parallel 1

