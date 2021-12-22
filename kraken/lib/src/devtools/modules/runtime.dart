/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
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
