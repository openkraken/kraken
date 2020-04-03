import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class KrakenSDKPlugin {
  static VoidCallback reloadListener;
  static const MethodChannel _channel = const MethodChannel('kraken_sdk');

  static void setReloadListener(VoidCallback reloadListener) {
    KrakenSDKPlugin.reloadListener = reloadListener;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> getUrl() async {
    return await _channel.invokeMethod('getUrl');
  }
}
