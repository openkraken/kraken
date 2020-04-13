/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:kraken/bridge.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';

import 'bundle.dart';

typedef ConnectedCallback = void Function();

ElementManager elementManager;
ConnectedCallback _connectedCallback;
String _bundleURLOverride;
String _bundlePathOverride;
String _bundleContentOverride;

void runApp({
  bool enableDebug = false,
  bool showPerformanceOverlay = false,
  bool shouldInitializeBinding = true,
  ConnectedCallback afterConnected,
}) async {
  if (enableDebug) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    debugPaintSizeEnabled = true;
  }

  if (shouldInitializeBinding) {
    /// Bootstrap binding
    ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();
  }

  if (afterConnected != null) _connectedCallback = afterConnected;

  await connect(showPerformanceOverlay);
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

/// Connect render object to start rendering.
Future<void> connect(bool showPerformanceOverlay) {
  Completer<void> completer = Completer();
  RendererBinding.instance.scheduleFrameCallback((_) {
    elementManager = ElementManager();
    elementManager.connect(showPerformanceOverlay: showPerformanceOverlay);

    if (_connectedCallback != null) {
      _connectedCallback();
    }

    completer.complete();
  });
  return completer.future;
}

// See http://github.com/flutter/flutter/wiki/Desktop-shells
/// If the current platform is a desktop platform that isn't yet supported by
/// TargetPlatform, override the default platform to one that is.
/// Otherwise, do nothing.
/// No need to handle macOS, as it has now been added to TargetPlatform.
void _setTargetPlatformForDesktop() {
  if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}


void defaultAfterConnected() async {
  // The bundleURL is a mix of local asset and remote resource in http.
  String bundleURL = _bundleURLOverride
      ?? _bundlePathOverride
      ?? getBundleURLFromEnv()
      ?? getBundlePathFromEnv()
      ?? await KrakenMethodChannel.getUrl();
  KrakenBundle bundle = await KrakenBundle.getBundle(bundleURL, contentOverride: _bundleContentOverride);
  if (bundle != null) {
    await bundle.run();

    // @TODO: refactor emit window load event.
    requestAnimationFrame((_) {
      String json = jsonEncode([WINDOW_ID, Event('load')]);
      emitUIEvent(json);
    });
  } else {
    print('ERROR: No bundle found.');
  }
}

void launch({
  String bundleURLOverride,
  String bundlePathOverride,
  String bundleContentOverride,
}) {
  if (bundleURLOverride != null) _bundleURLOverride = bundleURLOverride;
  if (bundlePathOverride != null) _bundlePathOverride = bundlePathOverride;
  if (bundleContentOverride != null) _bundleContentOverride = bundleContentOverride;

  initBridge();
  _setTargetPlatformForDesktop();
  KrakenMethodChannel.setReloadHandler(reloadApp);
  runApp(
    enableDebug: Platform.environment[ENABLE_DEBUG] != null,
    showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
    afterConnected: defaultAfterConnected,
  );
}
