/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'from_native.dart';
import 'to_native.dart';
import 'dart:ffi';

/// Init bridge
Pointer<JSContext> initBridge(int poolSize, bool firstView) {
  // Register methods first to share ptrs for bridge polyfill.
  registerDartMethodsToCpp();

  if (firstView) {
    return initJSContextPool(poolSize);
  } else {
    int contextIndex = allocateNewContext();
    return getJSContext(contextIndex);
  }
}
