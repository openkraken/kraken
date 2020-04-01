/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/src/bridge/from_native.dart';

/// A Message Channel bridge which will by pass messages to iOS or Android
/// from Javascript side.
/// Message format can be JSON, string or ArrayBuffer format of Javascript.

Map<String, MethodChannel> _clientMap = {};
int _clientId = 0;

class KrakenMessageChannel {
  static String init(String name) {
    MethodChannel channel = MethodChannel(name);
    channel.setMethodCallHandler((MethodCall call) async {
      emitModuleEvent('["${call.method}", ${jsonEncode(call.arguments)}]');
    });
    var id = (_clientId++).toString();
    _clientMap[id] = channel;
    return id;
  }

  static Future<String> invokeMethod(String id, String method, String args) async {
    MethodChannel channel = _clientMap[id];
    String result = await channel.invokeMethod<String>(method, args);
    return result;
  }
}
