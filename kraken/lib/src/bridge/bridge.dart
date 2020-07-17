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
int initBridge() {
  // Register methods first to share ptrs for bridge polyfill.
  registerDartMethodsToCpp();

  if (_firstView) {
    initJSContextPool(kKrakenJSBridgePoolSize);
    _firstView = false;
    return 0;
  } else {
    int contextIndex = allocateNewContext();
    print(contextIndex);
    if (contextIndex == -1) {
      throw new Exception('can\' allocate new kraken js Bridge: bridge count had reach the maximum size.');
    }
    return contextIndex;
  }
}
