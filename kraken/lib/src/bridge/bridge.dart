/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'from_native.dart';
import 'to_native.dart';

/// Init bridge
int initBridge(int poolSize, bool firstView) {
  // Register methods first to share ptrs for bridge polyfill.
  registerDartMethodsToCpp();

  if (firstView) {
    initJSContextPool(poolSize);
    return 0;
  } else {
    int contextIndex = allocateNewContext();
    return contextIndex;
  }
}
