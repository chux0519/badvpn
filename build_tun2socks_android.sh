#!/bin/bash

export ANDROID_USE_SHARED_LIBC=ON
. universal-android-toolchain/toolchain.sh "$@"

rm -rf build && mkdir build && cd build

export CFLAGS="$CFLAGS -DBADVPN_LINUX -DBADVPN_USE_SIGNALFD -DBADVPN_USE_EPOLL -DNDEBUG"

android_cmake_command \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_NOTHING_BY_DEFAULT=ON \
    -DBUILD_TUN2SOCKS=ON \
    ..

"$CMAKE/bin/cmake" --build . --config Debug

find ./ -type f -name "*.so" -exec cp {} $OUTPUT_DIR/ \;

cp $CURRENT_DIR/tun2socks/tun2socks.h $OUTPUT_DIR/../
