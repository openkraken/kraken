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
import 'package:requests/requests.dart';

import 'bundle.dart';
import 'command.dart';


const String BUNDLE_URL = 'KRAKEN_BUNDLE_URL';
const String BUNDLE_PATH = 'KRAKEN_BUNDLE_PATH';
const String COMMAND_PATH = 'KRAKEN_INSTRUCT_PATH';
const String ENABLE_DEBUG = 'KRAKEN_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'KRAKEN_ENABLE_PERFORMANCE_OVERLAY';
const String DEFAULT_BUNDLE_PATH = 'assets/bundle.js';
const String ZIP_BUNDLE_URL = "KRAKEN_ZIP_BUNDLE_URL";

typedef ConnectedCallback = void Function();
ElementManager elementManager;
ConnectedCallback _connectedCallback;

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
    RendererBinding.instance.addPostFrameCallback((time) {
      invokeOnloadCallback();
    });
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

String getCommandPathFromEnv() {
  return Platform.environment[COMMAND_PATH];
}

Future<String> getBundleContent({String bundleUrl, String bundlePath, String zipBundleUrl}) async {
  if (bundleUrl != null) {
    return Requests.get(bundleUrl).then((Response response) => response.content());
  }

  if (bundlePath != null) {
    String content = File(bundlePath).readAsStringSync(encoding: utf8);
    return Future<String>.value(content);
  }

  if (zipBundleUrl != null) {
    return await BundleManager().downloadAndParse(zipBundleUrl);
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

void afterConnectedForCommand() async {
  CommandRun(getCommandPathFromEnv()).run();
}

void afterConnected() async {
  String bundleUrl = getBundleURLFromEnv();
  String bundlePath = getBundlePathFromEnv();
  String zipBundleUrl = getZipBundleURLFromEnv();
  String content = await getBundleContent(bundleUrl: bundleUrl, bundlePath: bundlePath, zipBundleUrl: zipBundleUrl);
  evaluateScripts(content, bundleUrl ?? bundlePath ?? zipBundleUrl ?? DEFAULT_BUNDLE_PATH, 0);
}

void launch() {
  initBridge();
  _setTargetPlatformForDesktop();
  runApp(
    enableDebug: Platform.environment[ENABLE_DEBUG] != null,
    showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
    afterConnected: Platform.environment[COMMAND_PATH] != null ? afterConnectedForCommand : afterConnected
  );
}
