#!/bin/sh

pushd ffmpeg

./configure
make -j $(sysctl -n hw.ncpu)

popd

