import 'package:kraken/dom.dart';
import '../module.dart';
import '../inspector.dart';

const int DOCUMENT_NODE_ID = -3;

class InspectDOMModule extends InspectModule {
  @override
  String get name => 'DOM';

  final Inspector inspector;
  ElementManager get elementManager => inspector.elementManager;
  InspectDOMModule(this.inspector);

  @override
  void receiveFromBackend(int id, String method, Map<String, dynamic> params) {
    switch (method) {
      case 'getDocument':
        onGetDocument(id, method, params);
        break;
      case 'getBoxModel':
        onGetBoxModel(id, params);
        break;
      case 'setInspectedNode':
        sendToBackend(id, null);
        break;
    }
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-getDocument
  void onGetDocument(int id, String method, Map<String, dynamic> params) {
    Node root = elementManager.getRootElement();
    InspectorDocument document = InspectorDocument(
      InspectorNode(root)
    );

    sendToBackend(id, document);
  }

  void onGetBoxModel(int id, Map<String, dynamic> params) {
    // int nodeId = params['nodeId'];
    sendToBackend(id, null);
  }
}

class InspectorDocument extends JSONEncodable {
  InspectorNode child;

  InspectorDocument(this.child);

  @override
  Map toJson() {
    ElementManager elementManager = child.referencedNode.elementManager;
    return {
      'root': {
        'nodeId': DOCUMENT_NODE_ID,
        'backendNodeId': DOCUMENT_NODE_ID,
        'nodeType': 9,
        'nodeName': '#document',
        'childNodeCount': 1,
        'children': [child.toJson()],
        'baseURL': elementManager.controller.bundleURL,
        'documentURL': elementManager.controller.bundleURL,
      },
    };
  }
}

/// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#type-Node
class InspectorNode extends JSONEncodable {
  /// DOM interaction is implemented in terms of mirror objects that represent the actual
  /// DOM nodes. DOMNode is a base node mirror type.
  InspectorNode(this.referencedNode) : assert(referencedNode != null);

  /// Reference backend Kraken DOM Node.
  Node referencedNode;

  /// Node identifier that is passed into the rest of the DOM messages as the nodeId.
  /// Backend will only push node with given id once. It is aware of all requested nodes
  /// and will only fire DOM events for nodes known to the client.
  int get nodeId => referencedNode.targetId;

  /// Optional. The id of the parent node if any.
  int get parentId {
    if (referencedNode.parent != null) {
      return referencedNode.parent.targetId;
    } else {
      return 0;
    }
  }

  /// The BackendNodeId for this node.
  /// Unique DOM node identifier used to reference a node that may not have been pushed to
  /// the front-end.
  int backendNodeId = 0;

  /// [Node]'s nodeType.
  int get nodeType => getNodeTypeValue(referencedNode.nodeType);

  /// Node's nodeName.
  String get nodeName => referencedNode.nodeName.toLowerCase();

  /// Node's localName.
  String localName;

  /// Node's nodeValue.
  String get nodeValue {
    if (referencedNode.nodeType == NodeType.TEXT_NODE) {
      TextNode textNode = referencedNode;
      return textNode.data;
    } else if (referencedNode.nodeType == NodeType.COMMENT_NODE) {
      Comment comment = referencedNode;
      return comment.data;
    } else {
      return '';
    }
  }

  int get childNodeCount => referencedNode.childNodes.length;

  List<String> get attributes {
    if (referencedNode.nodeType == NodeType.ELEMENT_NODE) {
      List<String> attrs = [];
      Element el = referencedNode;
      el.properties.forEach((key, value) {
        attrs.add(key);
        attrs.add(value.toString());
      });
      return attrs;
    } else {
      return null;
    }
  }

  Map toJson() {
    return {
      'nodeId': nodeId,
      'backendNodeId': backendNodeId,
      'nodeType': nodeType,
      'localName': localName,
      'nodeName': nodeName,
      'nodeValue': nodeValue,
      'parentId': parentId,
      'childNodeCount': childNodeCount,
      'attributes': attributes,
      if (childNodeCount > 0)
        'children': referencedNode.childNodes.map((Node node) => InspectorNode(node).toJson()).toList(),
    };
  }
}
