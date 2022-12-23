/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'package:kraken/devtools.dart';

class InspectRuntimeModule extends IsolateInspectorModule {
  InspectRuntimeModule(IsolateInspectorServer server): super(server);

  @override
  String get name => 'Runtime';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    callNativeInspectorMethod(id, method, params);
  }
}
