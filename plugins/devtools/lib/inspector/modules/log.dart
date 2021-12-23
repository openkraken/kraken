import '../module.dart';
import '../isolate_server.dart';

class InspectorLogModule extends IsolateInspectorModule {
  InspectorLogModule(IsolateInspectorServer server): super(server);

  @override
  String get name => 'Log';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    callNativeInspectorMethod(id, method, params);
  }
}
