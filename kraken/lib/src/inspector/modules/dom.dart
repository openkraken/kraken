import 'package:kraken/dom.dart';
import '../module.dart';
import '../inspector.dart';

class InspectDOMModule extends InspectModule {
  @override
  String get name => 'DOM';

  final Inspector inspector;
  ElementManager get elementManager => inspector.elementManager;
  InspectDOMModule(this.inspector);

  @override
  void receiveFromBackend(String method, Map<String, dynamic> params) {
    switch (method) {
      case 'getDocument':
        onGetDocument(params);
        break;
    }
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-getDocument
  void onGetDocument(Map<String, dynamic> params) {
    Node root = elementManager.getRootElement();
    // sendToBackend(method, params);
  }
}


