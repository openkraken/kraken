
import 'package:kraken/inspector.dart';
import 'package:kraken/dom.dart';
import '../module.dart';

class InspectOverlayModule extends UIInspectorModule {
  @override
  String get name => 'Overlay';

  ElementManager get elementManager => inspector.viewController.elementManager;
  InspectOverlayModule(UIInspector inspector): super(inspector);

  @override
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params) {
    switch (method) {
      case 'highlightNode':
        onHighlightNode(id, params);
        break;
      case 'hideHighlight':
        onHideHighlight(id);
        break;
    }
  }

  Element _highlightElement;
  /// https://chromedevtools.github.io/devtools-protocol/tot/Overlay/#method-highlightNode
  void onHighlightNode(int id, Map<String, dynamic> params) {
    _highlightElement?.debugHideHighlight();

    int nodeId = params['nodeId'];
    Element element = elementManager.getEventTargetByTargetId<Element>(nodeId);

    if (element != null) {
      element.debugHighlight();
      _highlightElement = element;
    }
    sendToFrontend(id, null);
  }

  void onHideHighlight(int id) {
    _highlightElement?.debugHideHighlight();
    _highlightElement = null;
    sendToFrontend(id, null);
  }
}

