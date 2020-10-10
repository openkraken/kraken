import 'dart:io' show HttpServer, HttpRequest, WebSocket, WebSocketTransformer;
import 'dart:convert' show json;

import 'package:kraken/element.dart';
import 'package:kraken/css.dart' as css;

String ZERO_PX = '0px';

Function kebabize = (String str) {
  RegExp kababRE = RegExp(r'[A-Z]');
  return str.replaceAllMapped(kababRE, (match) => '-${match[0].toLowerCase()}');
};

Function standardizeNumber = (double number) {
  return "${(number * 100000).round() / 100000}px";
};

Function getLocalName = (String name) {
  switch (name) {
    case DIV:
    case SPAN:
    case BODY:
    case ANCHOR:
    case STRONG:
    case IMAGE:
    case PARAGRAPH:
    case INPUT:
    case PRE:
    case CANVAS:
    case ANIMATION_PLAYER:
    case VIDEO:
    case CAMERA_PREVIEW:
    case IFRAME:
    case AUDIO:
    case OBJECT:
      {
        return name.toLowerCase();
      }
      break;

    default:
      {
        return css.EMPTY_STRING;
      }
  }
};

Map initComputedStyle = {
  'width': '300px',
  'height': '150px',
  'border-left-width': ZERO_PX,
  'border-right-width': ZERO_PX,
  'border-top-width': ZERO_PX,
  'border-bottom-width': ZERO_PX,
  'margin-left': ZERO_PX,
  'margin-right': ZERO_PX,
  'margin-top': ZERO_PX,
  'margin-bottom': ZERO_PX,
  'padding-left': ZERO_PX,
  'padding-right': ZERO_PX,
  'padding-top': ZERO_PX,
  'padding-bottom': ZERO_PX,
  'position': 'static'
};

Map initDocument = {
  'backendNodeId': -2,
  'childNodeCount': 1,
  'children': [],
  'nodeName': '#document',
  'localName': '',
  'nodeValue': '',
  'nodeType': 9,
  'nodeId': -1,
};

Map initInlineStyle = {
  'shorthandEntries': [],
  'cssProperties': [],
  'cssText': '',
  'range': {'endColumn': 0, 'endLine': 0, 'startColumn': 0, 'startLine': 0}
};

class DevWebsocket {
  int count = 0;
  Map<int, Node> nodeIdMap = {};
  Node rootNode;
  double viewportWidth;
  double viewportHeight;

  DevWebsocket(this.viewportWidth, this.viewportHeight, rootElement) {
    setRoot(rootElement);
    init();
  }

  void init() {
    // create websocket server
    HttpServer.bind('localhost', 8082).then((HttpServer server) {
      print('DevTool WebSocket listening at -- ws://localhost:8082');
      print(
          'devtools://devtools/bundled/inspector.html?experiments=true&ws=localhost:8082');
      server.listen((HttpRequest request) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          ws.listen((message) {
            handleResponse(message, ws);
          });
        });
      }, onError: (error) => print(error));
    }, onError: (error) => print(error));
  }

  // handle devTool protocol methods
  void handleResponse(String message, WebSocket ws) {
    var data = json.decode(message);
    String result;
    switch (data['method']) {
      case 'DOM.getDocument':
        {
          if (rootNode != null)
            result = json.encode({
              'id': data['id'],
              'result': {'root': getDocument()}
            });
          else {
            result = json.encode({'node': data['id'], 'result': {}});
          }
          ws.add(result);
        }
        break;
      case 'DOM.requestChildNodes':
        {
          var nodeId = data['params']['nodeId'];
          var children = [];
          nodeIdMap[nodeId].childNodes.forEach((node) {
            nodeIdMap[count] = node;
            children.add(nodeToMap(node, count++));
          });
          result = json.encode({
            'method': 'DOM.setChildNodes',
            'params': {
              'parentId': nodeId,
              'nodes': children,
            },
          });
          String response = json.encode({'id': data['id'], 'result': {}});
          ws.add(result);
          ws.add(response);
        }
        break;
      case 'CSS.getMatchedStylesForNode':
        {
          int nodeId = data['params']['nodeId'];
          String res = json.encode({
            'id': data['id'],
            'result': {
              'inlineStyle': getInlineStyle(nodeId),
              'inherited': [],
              'pseudoElements': [],
              'cssKeyframesRules': [],
              'matchedCSSRules': []
            },
          });
          ws.add(res);
        }
        break;
      case 'CSS.getComputedStyleForNode':
        {
          int nodeId = data['params']['nodeId'];
          String res = json.encode({
            'id': data['id'],
            'result': {'computedStyle': getComputedStyle(nodeId)}
          });
          ws.add(res);
        }
        break;
      default:
        {
          result = json.encode({'id': data['id'], 'result': {}});
          ws.add(result);
        }
        break;
    }
  }

  // transfer node to protocol format
  Map nodeToMap(Node node, int id) {
    Map nodeMap = {};

    int nodeCount = node.childNodes.length;
    if (nodeCount > 0) {
      nodeMap['childNodeCount'] = nodeCount;
    }

    if (node.childNodes.length == 1) {
      Node child = node.childNodes[0];
      if (child.nodeName == '#text') {
        nodeIdMap[count] = child;
        nodeMap['children'] = [nodeToMap(child, count++)];
      }
    }

    nodeMap['nodeName'] = node.nodeName;
    nodeMap['localName'] = getLocalName(node.nodeName);
    nodeMap['backendNodeId'] = node.targetId;
    nodeMap['nodeId'] = id;
    nodeMap['nodeValue'] = '';
    nodeMap['nodeType'] = node.nodeType.index + 1;

    if (node is TextNode) {
      nodeMap['nodeValue'] = node.data;
      nodeMap['nodeType'] = 3;
    }

    if (node is Comment) {
      nodeMap['nodeType'] = 8;
    }

    if (node is Element) {
      List attribute = [];
      node.properties.forEach((key, value) {
        attribute.add(key);
        attribute.add(value);
      });

      nodeMap['attributes'] = attribute;

      // inline-style attribute disabled temporarily

      // CSSStyleDeclaration style = node.style;
      // if (style.length > 0) {
      //   String cssText = '';
      //   for (int i = 0; i < node.style.length; i++) {
      //   String camelizedProperty = style.item(i);
      //   String kebabizeProperty = kebabize(camelizedProperty);
      //   String prepertyValue = style.getPropertyValue(camelizedProperty);
      //   if (cssText.isNotEmpty) cssText += ' ';
      //   cssText += '$kebabizeProperty: $prepertyValue;';
      //   }
      //   attribute.add('style');
      //   attribute.add(cssText);
      // }
    }

    return nodeMap;
  }

  // handle inline style method
  Map getInlineStyle(int nodeId) {
    Node node = nodeIdMap[nodeId];
    Map inlineStyle = new Map.from(initInlineStyle);

    // if (node is TextNode) {
    //   node = node.parent;
    // }

    if (node is Element && node.style.length > 0) {
      css.CSSStyleDeclaration style = node.style;
      List cssProperties = [];
      String cssText = '';

      for (int i = 0; i < style.length; i++) {
        Map cssItem = {};
        String camelizedProperty = style.item(i);
        String kebabizeProperty = kebabize(camelizedProperty);
        String propertyValue = style.getPropertyValue(camelizedProperty);
        if (cssText.isNotEmpty) cssText += ' ';
        String text = '${kebabizeProperty}: ${propertyValue};';
        Map range = {
          'startLine': 0,
          'endLine': 0,
          'startColumn': cssText.length,
          'endColumn': cssText.length + text.length
        };
        cssText += text;
        cssItem['name'] = kebabizeProperty;
        cssItem['value'] = propertyValue;
        cssItem['text'] = text;
        cssItem['range'] = range;
        cssProperties.add(cssItem);
      }

      inlineStyle['cssText'] = cssText;
      inlineStyle['cssProperties'] = cssProperties;
      inlineStyle['range'] = {
        'startColumn': 0,
        'startLine': 0,
        'endLine': 0,
        'endColumn': cssText.length
      };
    }

    inlineStyle['styleSheetId'] = nodeId;
    return inlineStyle;
  }

  // handle computed style
  List getComputedStyle(int nodeId) {
    Node node = nodeIdMap[nodeId];
    Map computedStyle = new Map.from(initComputedStyle);
    List styleList = [];

    print('nodeType is Element: ${node is Element}');
    print('nodeType is What: ${node.nodeType}');

    // if (node is TextNode) {
    //   node = node.parent;
    // }

    if (node is Element) {
      css.CSSStyleDeclaration style = node.style;
      computedStyle['display'] = node.defaultDisplay;

      for (int i = 0; i < style.length; i++) {
        String camelizedProperty = style.item(i);
        String kebabizeProperty = kebabize(camelizedProperty);
        String propertyValue = style.getPropertyValue(camelizedProperty);
        if (propertyValue.contains(RegExp(r'vw|vh'))) {
          if (propertyValue.contains('vw')) {
            double pxWidth = double.parse(propertyValue.replaceAll('vw', '')) *
                viewportWidth;
            if (pxWidth == 0) {
              propertyValue = ZERO_PX;
            } else {
              propertyValue = standardizeNumber(pxWidth);
            }
          }
          if (propertyValue.contains('vh')) {
            double pxHeight = double.parse(propertyValue.replaceAll('vh', '')) *
                viewportHeight;
            if (pxHeight == 0) {
              propertyValue = ZERO_PX;
            } else
              propertyValue = standardizeNumber(pxHeight);
          }
        }
        computedStyle[kebabizeProperty] = propertyValue;
      }

      Map Rect = json.decode(node.getBoundingClientRect());
      Rect.forEach((key, value) {
        computedStyle[key] = standardizeNumber(value);
      });
    }

    computedStyle.forEach((key, value) {
      styleList.add({'name': key, 'value': value});
    });

    return styleList;
  }

  // handle getDocument method
  Map getDocument() {
    Map body = {};
    body = nodeToMap(rootNode, 0);
    body['children'] = [];
    rootNode.childNodes.forEach((node) {
      nodeIdMap[count] = node;
      body['children'].add(nodeToMap(node, count++));
    });

    Map document = new Map.from(initDocument);
    document['children'] = [body];

    return document;
  }

  void setRoot(Element root) {
    nodeIdMap[count++] = root;
    rootNode = root;
  }

  Node get Root {
    return rootNode;
  }
}
