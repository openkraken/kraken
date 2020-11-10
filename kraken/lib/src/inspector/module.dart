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
  void invoke(String method, Map<String, dynamic> params) {
    if (method == 'enable') {
      _enable = true;
    } else if (method == 'disable') {
      _enable = false;
    }

    if (_enable) {
      receiveFromBackend(method, params);
    }
  }

  void sendToBackend(String method, JSONEncodable params) {
    inspector.server.sendToBackend('$name.$method', params);
  }

  void receiveFromBackend(String method, Map<String, dynamic> params);
}
