import 'package:kraken/inspector.dart';
import 'package:kraken/dom.dart';
import '../module.dart';

const String DEFAULT_ISOLATE_ID = 'isolate_0';

class InspectRuntimeModule extends InspectModule {
  final Inspector inspector;

  ElementManager get elementManager => inspector.elementManager;

  InspectRuntimeModule(this.inspector);

  @override
  String get name => 'Runtime';

  @override
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params) {
    switch (method) {
      case 'enable':
        enable();
        break;
      case 'runIfWaitingForDebugger':
        sendToFrontend(id, null);
        break;
      case 'getIsolateId':
        onGetIsolateId(id, params);
        break;
    }
  }

  void enable() {
    sendEventToFrontend(InspectorEvent('executionContextCreated', JSONEncodableMap({
      'context': {
        'auxData': {
          'isDefault': true,
          'type': 'default',
          'frameId': DEFAULT_FRAME_ID,
        },
        'id': 1,
        'origin': elementManager.controller.bundleURL,
        'name': '',
      },
    })));
  }

  void onGetIsolateId(int id, Map<String, dynamic> params) {
    sendToFrontend(id, JSONEncodableMap({ 'id': DEFAULT_ISOLATE_ID }));
  }
}
