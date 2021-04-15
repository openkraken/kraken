import 'package:kraken/inspector.dart';
import '../module.dart';

class InspectRuntimeModule extends IsolateInspectorModule {
  InspectRuntimeModule(IsolateInspectorServer server): super(server);

  @override
  String get name => 'Runtime';

  @override
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params) {
    callNativeInspectorMethod(id, method, params);
  }
}
