/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

library kraken;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

import 'bridge.dart';
import 'element.dart';

export 'bridge.dart';

typedef ConnectedCallback = void Function();
ElementManager elementManager;
ConnectedCallback _connectedCallback;

Future<void> connect(bool showPerformanceOverlay) {
  Completer<void> completer = Completer();
  RendererBinding.instance.scheduleFrameCallback((Duration time) {
    elementManager = ElementManager();
    elementManager.connect(showPerformanceOverlay: showPerformanceOverlay);

    if (_connectedCallback != null) {
      _connectedCallback();
    }

    completer.complete();
    RendererBinding.instance.addPostFrameCallback((time) {
      invokeOnloadCallback();
    });
  });
  return completer.future;
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

Future<void> unmountApp() async {
  if (elementManager != null) {
    await elementManager.disconnect();
    elementManager = null;
  }
}

// refresh flutter paint and reload js context
void reloadApp() async {
  bool prevShowPerformanceOverlay = elementManager?.showPerformanceOverlay ?? false;
  await unmountApp();
  await reloadJSContext();
  await connect(prevShowPerformanceOverlay);
}

// refresh flutter paint only
Future<void> refreshPaint() async {
  bool prevShowPerformanceOverlay = elementManager?.showPerformanceOverlay ?? false;
  await unmountApp();
  await connect(prevShowPerformanceOverlay);
}
