read_version() {
  VERSION_STR=$(cat kraken.podspec | grep s.version | awk '{print $3}')
  END_POS=$(echo ${#VERSION_STR} - 2 | bc)
  export VERSION=${VERSION_STR:1:$END_POS}
}

if [ -L "libkraken.dylib" ]; then
  ROOT=$(pwd)
  rm libkraken.dylib
  ln -s $ROOT/../../bridge/build/macos/lib/x86_64/libkraken.dylib
fi
