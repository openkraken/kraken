import 'dart:ui' as ui;

import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:flutter/rendering.dart';
import '../module.dart';
import '../ui_inspector.dart';

const int DOCUMENT_NODE_ID = -3;
const String DEFAULT_FRAME_ID = 'main_frame';

class InspectDOMModule extends UIInspectorModule {
  @override
  String get name => 'DOM';

  ElementManager get elementManager => inspector.viewController.elementManager;
  InspectDOMModule(UIInspector inspector): super(inspector);

  @override
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params) {
    switch (method) {
      case 'getDocument':
        onGetDocument(id, method, params);
        break;
      case 'getBoxModel':
        onGetBoxModel(id, params);
        break;
      case 'setInspectedNode':
        onSetInspectedNode(id, params);
        break;
      case 'getNodeForLocation':
        onGetNodeForLocation(id, params);
        break;
    }
  }

  void onGetNodeForLocation(int id, Map<String, dynamic> params) {
    int x = params['x'];
    int y = params['y'];

    RenderBox rootRenderObject = elementManager.getRootRenderObject();
    BoxHitTestResult result = BoxHitTestResult();
    rootRenderObject.hitTest(result, position: Offset(x.toDouble(), y.toDouble()));
    if (result.path.first != null && result.path.first.target is RenderBoxModel) {
      RenderBoxModel lastHitRenderBoxModel = result.path.first.target;
      int targetId = lastHitRenderBoxModel.targetId;
      sendToFrontend(id, JSONEncodableMap({
        'backendId': targetId,
        'frameId': DEFAULT_FRAME_ID,
        'nodeId': targetId,
      }));
    } else {
      sendToFrontend(id, null);
    }
  }

  /// Enables console to refer to the node with given id via $x
  /// (see Command Line API for more details $x functions).
  Node inspectedNode;

  void onSetInspectedNode(int id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    Node node = elementManager.getEventTargetByTargetId(nodeId);
    if (node != null) {
      inspectedNode = node;
    }
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-getDocument
  void onGetDocument(int id, String method, Map<String, dynamic> params) {
    Node root = elementManager.getRootElement();
    InspectorDocument document = InspectorDocument(
      InspectorNode(root)
    );

    sendToFrontend(id, document);
  }

  void onGetBoxModel(int id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    Element element = elementManager.getEventTargetByTargetId<Element>(nodeId);

    // BoxModel design to BorderBox in kraken.
    if (element != null && element.renderBoxModel != null && element.renderBoxModel.hasSize) {
      ui.Offset contentBoxOffset = element.renderBoxModel.localToGlobal(ui.Offset.zero);

      int widthWithinBorder = element.renderBoxModel.size.width.toInt();
      int heightWithinBorder = element.renderBoxModel.size.height.toInt();
      List<double> border = [
        contentBoxOffset.dx, contentBoxOffset.dy,
        contentBoxOffset.dx + widthWithinBorder, contentBoxOffset.dy,
        contentBoxOffset.dx + widthWithinBorder, contentBoxOffset.dy + heightWithinBorder,
        contentBoxOffset.dx, contentBoxOffset.dy + heightWithinBorder,
      ];
      List<double> padding = [
        border[0] + element.renderBoxModel.renderStyle.borderLeft, border[1] + element.renderBoxModel.renderStyle.borderTop,
        border[2] - element.renderBoxModel.renderStyle.borderRight, border[3] + element.renderBoxModel.renderStyle.borderTop,
        border[4] - element.renderBoxModel.renderStyle.borderRight, border[5] - element.renderBoxModel.renderStyle.borderBottom,
        border[6] + element.renderBoxModel.renderStyle.borderLeft, border[7] - element.renderBoxModel.renderStyle.borderBottom,
      ];
      List<double> content = [
        padding[0] + element.renderBoxModel.renderStyle.paddingLeft, padding[1] + element.renderBoxModel.renderStyle.paddingTop,
        padding[2] - element.renderBoxModel.renderStyle.paddingRight, padding[3] + element.renderBoxModel.renderStyle.paddingTop,
        padding[4] - element.renderBoxModel.renderStyle.paddingRight, padding[5] - element.renderBoxModel.renderStyle.paddingBottom,
        padding[6] + element.renderBoxModel.renderStyle.paddingLeft, padding[7] - element.renderBoxModel.renderStyle.paddingBottom,
      ];
      List<double> margin = [
        border[0] - element.renderBoxModel.renderStyle.marginLeft.length, border[1] - element.renderBoxModel.renderStyle.marginTop.length,
        border[2] + element.renderBoxModel.renderStyle.marginRight.length, border[3] - element.renderBoxModel.renderStyle.marginTop.length,
        border[4] + element.renderBoxModel.renderStyle.marginRight.length, border[5] + element.renderBoxModel.renderStyle.marginBottom.length,
        border[6] - element.renderBoxModel.renderStyle.marginLeft.length, border[7] + element.renderBoxModel.renderStyle.marginBottom.length,
      ];

      BoxModel boxModel = BoxModel(
        content: content,
        padding: padding,
        border: border,
        margin: margin,
        width: widthWithinBorder,
        height: heightWithinBorder,
      );
      sendToFrontend(id, JSONEncodableMap({
        'model': boxModel,
      }));
    } else {
      sendToFrontend(id, null);
    }
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

class BoxModel extends JSONEncodable {
  List<double> content;
  List<double> padding;
  List<double> border;
  List<double> margin;
  int width;
  int height;

  BoxModel({ this.content, this.padding, this.border, this.margin, this.width, this.height });

  @override
  Map toJson() {
    return {
      'content': content,
      'padding': padding,
      'border': border,
      'margin': content,
      'width': width,
      'height': height,
    };
  }
}

class Rect extends JSONEncodable {
  num x;
  num y;
  num width;
  num height;

  Rect({ this.x, this.y, this.width, this.height });

  @override
  Map toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}

