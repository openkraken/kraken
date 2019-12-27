import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:requests/requests.dart';
import 'package:kraken/kraken.dart';
import 'package:flutter/services.dart' show rootBundle;

const String BUNDLE_URL = 'KRAKEN_BUNDLE_URL';
const String BUNDLE_PATH = 'KRAKEN_BUNDLE_PATH';
const String ENABLE_DEBUG = 'KRAKEN_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'KRAKEN_ENABLE_PERFORMANCE_OVERLAY';
const String DEFAULT_BUNDLE_PATH = 'assets/bundle.js';

String getBundleURLFromEnv() {
  return Platform.environment[BUNDLE_URL];
}

String getBundlePathFromEnv() {
  return Platform.environment[BUNDLE_PATH];
}

Future<String> getBundleContent({ String bundleUrl, String bundlePath }) async {

  if (bundleUrl != null) {
    return Requests.get(bundleUrl).then((Response response) => response.content());
  }

  if (bundlePath != null) {
    String content = File(bundlePath).readAsStringSync(encoding: utf8);
    return Future<String>.value(content);
  }

  return await loadBundleFromAssets();
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

Future<String> loadBundleFromAssets() async {
  return await rootBundle.loadString(DEFAULT_BUNDLE_PATH);
}

void afterConnected() async {
  String bundleUrl = getBundleURLFromEnv();
  String bundlePath = getBundlePathFromEnv();
  String content = await getBundleContent(bundleUrl: bundleUrl, bundlePath: bundlePath);

  evaluateScripts(
    content,
    bundleUrl ?? bundlePath ?? DEFAULT_BUNDLE_PATH,
  );
}

void main() {
  initKrakenCallback();
  _setTargetPlatformForDesktop();
  runApp(
    enableDebug: Platform.environment[ENABLE_DEBUG] != null,
    showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
    afterConnected: afterConnected
  );
}
