if [ -L "kraken_bridge.framework" ]; then
  ROOT=$(pwd)
  rm kraken_bridge.framework
  ln -s $ROOT/../../bridge/build/ios/framework/kraken_bridge.framework
fi
