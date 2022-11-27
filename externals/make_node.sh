#!/bin/sh

pushd node

./configure --enable-static
make -j $(sysctl -n hw.ncpu)

popd

