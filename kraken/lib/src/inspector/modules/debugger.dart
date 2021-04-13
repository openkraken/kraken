import 'package:kraken/inspector.dart';
import 'package:kraken/dom.dart';

import '../module.dart';

class InspectDebuggerModule extends InspectModule {
  final Inspector inspector;

  InspectDebuggerModule(this.inspector);

  ElementManager get elementManager => inspector.elementManager;

  @override
  String get name => 'Debugger';

  @override
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params) {
    callNativeInspectorMethod(id, method, params);
  }
}
