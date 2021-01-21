

read_version() {
  VERSION_STR=$(cat kraken.podspec | grep s.version | awk '{print $3}')
  END_POS=$(echo ${#VERSION_STR} - 2 | bc)
  export VERSION=${VERSION_STR:1:$END_POS}
}

if [ ! -d "libkraken_jsc.dylib" ]; then
  read_version
  curl -O https://kraken.oss-cn-hangzhou.aliyuncs.com/kraken_bridge/$VERSION/libkraken_jsc.dylib
fi
