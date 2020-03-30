/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:kraken/bridge.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken_bundle/kraken_bundle.dart';
import 'package:requests/requests.dart';

import 'bundle.dart';


const String BUNDLE_URL = 'KRAKEN_BUNDLE_URL';
const String BUNDLE_PATH = 'KRAKEN_BUNDLE_PATH';
const String ENABLE_DEBUG = 'KRAKEN_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'KRAKEN_ENABLE_PERFORMANCE_OVERLAY';
const String DEFAULT_BUNDLE_PATH = 'assets/bundle.js';
const String ZIP_BUNDLE_URL = "KRAKEN_ZIP_BUNDLE_URL";

typedef ConnectedCallback = void Function();
ElementManager elementManager;
ConnectedCallback _connectedCallback;
String _bundleURLOverride;
String _bundlePathOverride;
String _zipBundleURLOverride;
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

  if (afterConnected != null) _connectedCallback = afterConnected;
  if (shouldInitializeBinding) {
    /// Bootstrap binding
    ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();
  }

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

String getBundleURLFromEnv() {
  return Platform.environment[BUNDLE_URL];
}

String getZipBundleURLFromEnv() {
  return Platform.environment[ZIP_BUNDLE_URL];
}

String getBundlePathFromEnv() {
  return Platform.environment[BUNDLE_PATH];
}

Future<String> getBundleContent({String bundleURL, String bundlePath, String zipBundleURL}) async {
  if (bundleURL != null) {
    return Requests.get(bundleURL).then((Response response) => response.content());
  }

  if (bundlePath != null) {
    String content = File(bundlePath).readAsStringSync(encoding: utf8);
    return Future<String>.value(content);
  }

  if (zipBundleURL != null) {
    return await BundleManager().downloadAndParse(zipBundleURL);
  }

  try {
    return await rootBundle.loadString(DEFAULT_BUNDLE_PATH);
  } catch (e) {
    print('ERROR: no bundle found');
  }

  return Future<String>.value('');
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
  String bundleURL = _bundleURLOverride ?? getBundleURLFromEnv() ?? await KrakenBundle.bundleUrl;
  String bundlePath = _bundlePathOverride ?? getBundlePathFromEnv();
  String zipBundleURL = _zipBundleURLOverride ?? getZipBundleURLFromEnv() ?? await KrakenBundle.zipBundleUrl;
  String content = _bundleContentOverride ?? await getBundleContent(bundleURL: bundleURL, bundlePath: bundlePath, zipBundleURL: zipBundleURL);
  evaluateScripts(content, bundleURL ?? bundlePath ?? zipBundleURL ?? DEFAULT_BUNDLE_PATH, 0);

  // Invoke onload after scripts executed.
  requestAnimationFrame((_) {
    invokeOnloadCallback();
  });
}


void launch({
  String bundleURLOverride,
  String bundlePathOverride,
  String zipBundleURLOverride,
  String bundleContentOverride,
}) {
  if (bundleURLOverride != null) _bundleURLOverride = bundleURLOverride;
  if (bundlePathOverride != null) _bundlePathOverride = bundlePathOverride;
  if (zipBundleURLOverride != null) _zipBundleURLOverride = zipBundleURLOverride;
  if (bundleContentOverride != null) _bundleContentOverride = bundleContentOverride;

  initBridge();
  _setTargetPlatformForDesktop();
  KrakenBundle.setReloadListener(reloadApp);
  runApp(
      enableDebug: Platform.environment[ENABLE_DEBUG] != null,
      showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
      afterConnected: defaultAfterConnected
  );
}
