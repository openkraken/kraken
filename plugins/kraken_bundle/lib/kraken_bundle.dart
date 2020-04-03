import 'dart:async';

import 'package:flutter/services.dart';

typedef ReloadListener = void Function();
class KrakenBundle {
  static ReloadListener reloadListener;
  static MethodChannel _channel = MethodChannel('kraken_bundle')
    ..setMethodCallHandler((call) async {
      if ('reload' == call.method && reloadListener != null) {
        await reloadListener();
      }
      return Future<dynamic>.value(null);
    });

  static void setReloadListener(ReloadListener reloadListener) {
    KrakenBundle.reloadListener = reloadListener;
  }

  static Future<String> getBundleUrl() async {
    String bundleUrl;
    try {
      bundleUrl = await _channel.invokeMethod('getBundleUrl');
    } catch (e) {
    }

    return bundleUrl;
  }

  static Future<String> getZipBundleUrl() async {
    String zipBundleUrl;
    try {
      zipBundleUrl = await _channel.invokeMethod('getZipBundleUrl');
    } catch (e) {
    }
    return zipBundleUrl;
  }

  static Future<String> getBundlePath() async {
    String bundlePath;
    try {
      bundlePath = await _channel.invokeMethod('getBundlePath');
    } catch (e) {}
    return bundlePath;
  }
}
