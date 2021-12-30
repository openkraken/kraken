/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/devtools.dart';

class InspectorLogModule extends IsolateInspectorModule {
  InspectorLogModule(IsolateInspectorServer server): super(server);

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
