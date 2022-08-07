ROOT=$(pwd)

if [ -L "kraken_bridge.xcframework" ]; then
  ROOT=$(pwd)
  rm kraken_bridge.xcframework
  ln -s $ROOT/../../bridge/build/ios/framework/kraken_bridge.xcframework
fi

if [ -L "quickjs.xcframework" ]; then
  ROOT=$(pwd)
  rm quickjs.xcframework
  ln -s $ROOT/../../bridge/build/ios/framework/quickjs.xcframework
fi
