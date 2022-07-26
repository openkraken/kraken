/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'package:kraken/devtools.dart';

class InspectDebuggerModule extends IsolateInspectorModule {
  InspectDebuggerModule(IsolateInspectorServer server): super(server);

  @override
  String get name => 'Debugger';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    callNativeInspectorMethod(id, method, params);
  }
}
