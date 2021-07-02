read_version() {
  VERSION_STR=$(cat kraken.podspec | grep s.version | awk '{print $3}')
  END_POS=$(echo ${#VERSION_STR} - 2 | bc)
  export VERSION=${VERSION_STR:1:$END_POS}
}

if [ -L "libkraken_jsc.dylib" ]; then
  ROOT=$(pwd)
  rm libkraken_jsc.dylib
  ln -s $ROOT/../../bridge/build/macos/lib/x86_64/libkraken_jsc.dylib
fi

if [ -L "libkraken_quickjs.dylib" ]; then
  ROOT=$(pwd)
  rm libkraken_quickjs.dylib
  ln -s $ROOT/../../bridge/build/macos/lib/x86_64/libkraken_quickjs.dylib
fi


if [ -L "libquickjs.dylib" ]; then
  ROOT=$(pwd)
  rm libquickjs.dylib
  ln -s $ROOT/../../bridge/build/macos/lib/x86_64/libquickjs.dylib
fi
