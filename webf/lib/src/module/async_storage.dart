/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:webf/src/module/module_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AsyncStorageModule extends BaseModule {
  @override
  String get name => 'AsyncStorage';

  static Future<SharedPreferences>? _prefs;

  AsyncStorageModule(ModuleManager? moduleManager) : super(moduleManager);

  /// Loads and parses the [SharedPreferences] for this app from disk.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  static Future<SharedPreferences> _getPrefs() {
    _prefs ??= SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<bool> setItem(String key, String value) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.setString(key, value);
  }

  static Future<String?> getItem(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString(key);
  }

  static Future<bool> removeItem(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.remove(key);
  }

  static Future<Set<String>> getAllKeys() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getKeys();
  }

  static Future<bool> clear() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.clear();
  }

  static Future<int> length() async {
    final SharedPreferences prefs = await _getPrefs();
    final Set<String> keys = prefs.getKeys();
    return keys.length;
  }

  @override
  void dispose() {}

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'getItem':
        AsyncStorageModule.getItem(params).then((String? value) {
          callback(data: value ?? '');
        }).catchError((e, stack) {
          callback(error: '$e\n$stack');
        });
        break;
      case 'setItem':
        String key = params[0];
        String value = params[1];
        AsyncStorageModule.setItem(key, value).then((bool isSuccess) {
          callback(data: isSuccess.toString());
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      case 'removeItem':
        AsyncStorageModule.removeItem(params).then((bool isSuccess) {
          callback(data: isSuccess.toString());
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      case 'getAllKeys':
        AsyncStorageModule.getAllKeys().then((Set<String> set) {
          List<String> list = List.from(set);
          callback(data: list);
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      case 'clear':
        AsyncStorageModule.clear().then((bool isSuccess) {
          callback(data: isSuccess.toString());
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      case 'length':
        AsyncStorageModule.length().then((int length) {
          callback(data: length);
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      default:
        throw Exception('AsyncStorage: Unknown method $method');
    }

    return '';
  }
}
