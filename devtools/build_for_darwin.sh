#!/bin/bash

BUILD_PATH="$PWD/build-darwin"
echo 'build-path:'$BUILD_PATH
rm -rf $BUILD_PATH

if [ ! -d "$BUILD_PATH" ]; then
  mkdir $BUILD_PATH
fi

# compile
pushd $BUILD_PATH
cmake ../ \
 -DKRAKEN_ROOT_DIR="$PWD/../.." \
 -G 'Xcode'
popd

echo 'iOS Xcode Project generated.'