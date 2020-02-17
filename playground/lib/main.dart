import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:flutter/services.dart' show rootBundle;
import 'package:kraken/kraken.dart';
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

Future<String> getBundleContent({String bundleUrl, String bundlePath}) async {
  if (bundleUrl != null) {
    return Requests.get(bundleUrl).then((Response response) => response.content());
  }

  if (bundlePath != null) {
    String content = File(bundlePath).readAsStringSync(encoding: utf8);
    return Future<String>.value(content);
  }

  // JSBundle only supports Android and iOS.
  String zipBundleUrl = getZipBundleURLFromEnv();
  if (zipBundleUrl != null && zipBundleUrl.isNotEmpty &&
      (Platform.isAndroid || Platform.isIOS)) {
    return await BundleManager().downloadAndParse(zipBundleUrl);
  }

  return Future<String>.value('');
}

// See http://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

void afterConnectedForCommand() async {
  CommandRun(getCommandPathFromEnv()).run();
}

void afterConnected() async {
  String bundleUrl = getBundleURLFromEnv();
  String bundlePath = getBundlePathFromEnv();
  String content = await getBundleContent(bundleUrl: bundleUrl, bundlePath: bundlePath);
  evaluateScripts(content, bundleUrl ?? bundlePath ?? DEFAULT_BUNDLE_PATH, 0);
}

void main() {
  initBridge();
  _setTargetPlatformForDesktop();
  runApp(
      enableDebug: Platform.environment[ENABLE_DEBUG] != null,
      showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
      afterConnected: Platform.environment[COMMAND_PATH] != null ? afterConnectedForCommand : afterConnected);
}
