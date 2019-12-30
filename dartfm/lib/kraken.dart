/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

library kraken;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'element.dart';
import 'bridge.dart';
export 'bridge.dart';

typedef ConnectedCallback = void Function();
ElementManager elementManager;

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

  if (shouldInitializeBinding) {
    /// Bootstrap binding
    ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();
  }

  RendererBinding.instance.scheduleFrameCallback((Duration time) {
    elementManager = ElementManager();
    elementManager.connect(showPerformanceOverlay: showPerformanceOverlay);

    if (afterConnected != null) {
      afterConnected();
    }
    RendererBinding.instance.addPostFrameCallback((time) {
      CPPMessage(WINDOW_LOAD, "").send();
    });
  });

  initScreenMetricsChangedCallback();
}

void unmountApp() {
  if (elementManager != null) {
    elementManager.disconnect();
    elementManager = null;
  }
}
