/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/devtools.dart';

class InspectLogModule extends UIInspectorModule {
  InspectLogModule(ChromeDevToolsService server) : super(server) {
    devtoolsService.controller!.onJSLog = (level, message) {
      handleMessage(level, message);
    };
  }

  void handleMessage(int level, String message) {
    sendEventToFrontend(LogEntryEvent(
      text: message,
      level: getLevelStr(level),
    ));
  }

  /// Log = 1,
  /// Warning = 2,
  /// Error = 3,
  /// Debug = 4,
  /// Info = 5,
  String getLevelStr(int level) {
    switch (level) {
      case 1:
        return 'verbose';
      case 2:
        return 'warning';
      case 3:
        return 'error';
      case 4:
        return 'verbose';
      case 5:
        return 'info';
      default:
        return 'verbose';
    }
  }

  @override
  String get name => 'Log';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    // callNativeInspectorMethod(id, method, params);
  }
}

class LogEntryEvent extends InspectorEvent {
  // Allowed Values: xml, javascript, network, storage, appcache,
  // rendering, security, deprecation, worker, violation, intervention,
  // recommendation, other
  String source;

  // Allowed Values: verbose, info, warning, error
  String level;

  // The output text.
  String text;

  String? url;

  LogEntryEvent({
    required this.level,
    required this.text,
    this.source = 'javascript',
    this.url,
  });

  @override
  String get method => 'Log.entryAdded';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'entry': {
          'source': source,
          'level': level,
          'text': text,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (url != null) 'url': url,
        },
      });
}
