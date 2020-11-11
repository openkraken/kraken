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

abstract class InspectModule {
  Inspector inspector;

  String get name;

  bool _enable = false;
  void invoke(int id, String method, Map<String, dynamic> params) {
    if (method == 'enable') {
      _enable = true;
      sendToBackend(id, null);
    } else if (method == 'disable') {
      _enable = false;
      sendToBackend(id, null);
    }

    if (_enable) {
      receiveFromBackend(id, method, params);
    }
  }

  void sendToBackend(int id, JSONEncodable result) {
    if (inspector.server.connected) {
      inspector.server.sendToBackend(id, result);
    }
  }

  void sendEventToBackend(InspectorEvent event) {
    if (inspector.server.connected) {
      inspector.server.sendEventToBackend(event);
    }
  }

  void receiveFromBackend(int id, String method, Map<String, dynamic> params);
}
