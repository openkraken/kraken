import 'dart:convert';

import 'package:kraken/inspector.dart';

export 'modules/dom.dart';
export 'modules/css.dart';
export 'modules/page.dart';
export 'modules/inspector.dart';
export 'modules/log.dart';
export 'modules/network.dart';
export 'modules/overlay.dart';
export 'modules/profiler.dart';
export 'modules/runtime.dart';
export 'modules/debugger.dart';

abstract class _InspectorModule {
  String get name;

  bool _enable = false;

  void invoke(int id, String method, Map<String, dynamic> params) {
    if (method == 'enable') {
      _enable = true;
      sendToFrontend(id, null);
    } else if (method == 'disable') {
      _enable = false;
      sendToFrontend(id, null);
    }

    if (_enable) {
      receiveFromFrontend(id, method, params);
    }
  }

  void sendToFrontend(int id, JSONEncodable result);
  void sendEventToFrontend(InspectorEvent event);
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params);
}

// Inspector modules working on flutter.ui thread.
abstract class UIInspectorModule extends _InspectorModule {
  final UIInspector inspector;
  UIInspectorModule(this.inspector);

  void sendToFrontend(int id, JSONEncodable result) {
    inspector.viewController.isolateServerPort.send(InspectorMethodResult(id, result?.toJson()));
  }
  void sendEventToFrontend(InspectorEvent event) {
    inspector.viewController.isolateServerPort.send(event);
  }
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params);
}

// Inspector modules working on dart isolates
abstract class IsolateInspectorModule extends _InspectorModule {
  IsolateInspectorModule(this.server);

  final IsolateInspectorServer server;

  void sendToFrontend(int id, JSONEncodable result) {
    server.sendToFrontend(id, result?.toJson());
  }

  void sendEventToFrontend(InspectorEvent event) {
    server.sendEventToFrontend(event);
  }

  void callNativeInspectorMethod(int id, String method, Map<String, dynamic> params) {
    assert(server.nativeInspectorMessageHandler != null);
    print('id: $id, method: $method');
    server.nativeInspectorMessageHandler(jsonEncode({'id': id, 'method': name + '.' + method, 'params': params}));
  }

  void receiveFromFrontend(int id, String method, Map<String, dynamic> params);
}
