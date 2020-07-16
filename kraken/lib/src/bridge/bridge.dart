/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'from_native.dart';
import 'to_native.dart';

/// the Kraken JS Bridge Size
int kKrakenJSBridgePoolSize = 8;

bool _firstView = true;

/// Init bridge
int initBridge(int bridgeIndex) {
  // Register methods first to share ptrs for bridge polyfill.
  registerDartMethodsToCpp();

  if (_firstView) {
    initJSBridgePool(kKrakenJSBridgePoolSize);
    _firstView = false;
    return 0;
  } else {
    int contextIndex = allocateNewBridge(bridgeIndex);
    if (contextIndex == -1) {
      throw new Exception('can\' allocate new kraken js Bridge: bridge count had reach the maximum size.');
    }
    return contextIndex;
  }
}
