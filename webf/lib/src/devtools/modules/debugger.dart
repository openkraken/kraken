/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/devtools.dart';

class InspectDebuggerModule extends IsolateInspectorModule {
  InspectDebuggerModule(IsolateInspectorServer server) : super(server);

  @override
  String get name => 'Debugger';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    callNativeInspectorMethod(id, method, params);
  }
}
