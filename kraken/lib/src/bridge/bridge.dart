/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'from_native.dart';
import 'to_native.dart';
import 'package:flutter/scheduler.dart';

/// the Kraken JS Bridge Size
int kKrakenJSBridgePoolSize = 8;

bool _firstView = true;

/// Init bridge
int initBridge() {
  // Register methods first to share ptrs for bridge polyfill.
  registerDartMethodsToCpp();

  int contextId = -1;
  // Port flutter's frame callback into bridge.
  SchedulerBinding.instance.addPersistentFrameCallback((_) {
    assert(contextId != -1);

    flushBridgeTask();
    flushUICommand();
    flushUICommandCallback(contextId);
  });

  if (_firstView) {
    initJSContextPool(kKrakenJSBridgePoolSize);
    _firstView = false;
    contextId = 0;
  } else {
    contextId = allocateNewContext();
    if (contextId == -1) {
      throw Exception('can\' allocate new kraken js Bridge: bridge count had reach the maximum size.');
    }
    return contextId;
  }

  return contextId;
}
