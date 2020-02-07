/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

library kraken;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'element.dart';
import 'bridge.dart';
export 'bridge.dart';

typedef ConnectedCallback = void Function();
ElementManager elementManager;
ConnectedCallback _connectedCallback;
bool appLoading = false;

void connect(bool showPerformanceOverlay) {
  RendererBinding.instance.scheduleFrameCallback((Duration time) {
    elementManager = ElementManager();
    elementManager.connect(showPerformanceOverlay: showPerformanceOverlay);

    if (_connectedCallback != null) {
      _connectedCallback();
    }
    RendererBinding.instance.addPostFrameCallback((time) {
      invokeOnloadCallback();
    });
    startFlushUILoop();
  });
}

void startFlushUILoop() {
  flushUITask();

  // flush ui task every 16ms
  Duration duration = Duration(milliseconds: 16);
  Timer(duration, () {
    startFlushUILoop();
  });
}

void runApp({
  bool enableDebug = false,
  bool showPerformanceOverlay = false,
  bool shouldInitializeBinding = true,
  ConnectedCallback afterConnected,
}) {
  if (enableDebug) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    debugPaintSizeEnabled = true;
  }

  if (afterConnected != null) _connectedCallback = afterConnected;
  if (shouldInitializeBinding) {
    /// Bootstrap binding
    ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();
  }

  connect(showPerformanceOverlay);
}

void unmountApp() {
  if (elementManager != null) {
    timer.reloadTimer();
    elementManager.disconnect();
    elementManager = null;
  }
}
