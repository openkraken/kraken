/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/module.dart';

import 'binding.dart';
import 'from_native.dart';
import 'to_native.dart';

/// The maximum webf pages running in the same times.
/// Can be upgrade to larger amount if you have enough memory spaces.
int kWebFJSPagePoolSize = 1024;

bool _firstView = true;

/// Init bridge
int initBridge() {
  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_BRIDGE_REGISTER_DART_METHOD_START);
  }

  // Register methods first to share ptrs for bridge polyfill.
  registerDartMethodsToCpp();

  // Setup binding bridge.
  BindingBridge.setup();

  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_BRIDGE_REGISTER_DART_METHOD_END);
  }

  int contextId = -1;

  // We should schedule addPersistentFrameCallback() to the next frame because of initBridge()
  // will be called from persistent frame callbacks and cause infinity loops.
  if (_firstView) {
    Future.microtask(() {
      // Port flutter's frame callback into bridge.
      SchedulerBinding.instance.addPersistentFrameCallback((_) {
        flushUICommand();
        flushUICommandCallback();
      });
    });
  }

  if (_firstView) {
    initJSPagePool(kWebFJSPagePoolSize);
    _firstView = false;
    contextId = 0;
  } else {
    contextId = allocateNewPage();
    if (contextId == -1) {
      throw Exception('Can\' allocate new webf bridge: bridge count had reach the maximum size.');
    }
  }

  return contextId;
}
