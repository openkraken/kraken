/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/module.dart';

import 'from_native.dart';
import 'to_native.dart';

/// The maximum kraken pages running in the same times.
/// Can be upgrade to larger amount if you have enough memory spaces.
int kKrakenJSPagePoolSize = 1024;

bool _firstView = true;

/// Init bridge
int initBridge() {
  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_BRIDGE_REGISTER_DART_METHOD_START);
  }

  // Register methods first to share ptrs for bridge polyfill.
  registerDartMethodsToCpp();

  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_BRIDGE_REGISTER_DART_METHOD_END);
  }

  int contextId = -1;

  // We should schedule addPersistentFrameCallback() to the next frame because of initBridge()
  // will be called from persistent frame callbacks and cause infinity loops.
  if (_firstView) {
    Future.microtask(() {
      // Port flutter's frame callback into bridge.
      SchedulerBinding.instance!.addPersistentFrameCallback((_) {
        flushUICommand();
        flushUICommandCallback();
      });
    });
  }

  if (_firstView) {
    initJSPagePool(kKrakenJSPagePoolSize);
    _firstView = false;
    contextId = 0;
  } else {
    contextId = allocateNewPage();
    if (contextId == -1) {
      throw Exception('Can\' allocate new kraken bridge: bridge count had reach the maximum size.');
    }
  }

  return contextId;
}
