/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/services.dart';
import 'package:webf/src/module/module_manager.dart';

class ClipBoardModule extends BaseModule {
  @override
  String get name => 'Clipboard';
  ClipBoardModule(ModuleManager? moduleManager) : super(moduleManager);

  static Future<String> readText() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null) return '';
    return data.text ?? '';
  }

  static Future<void> writeText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  void dispose() {}

  @override
  String invoke(String method, params, callback) {
    if (method == 'readText') {
      ClipBoardModule.readText().then((String value) {
        callback(data: value);
      }).catchError((e, stack) {
        callback(error: '$e\n$stack');
      });
    } else if (method == 'writeText') {
      ClipBoardModule.writeText(params).then((_) {
        callback();
      }).catchError((e, stack) {
        callback(error: '');
      });
    }
    return '';
  }
}
