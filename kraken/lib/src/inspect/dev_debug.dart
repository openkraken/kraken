/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';
import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:kraken/element.dart';
import 'package:kraken/css.dart' hide PRE;
import 'package:kraken/src/inspect/css_parse.dart';

String ZERO_PX = '0px';

String KRAKEN_VERSION = 'Kraken';

String kebabize(String str) {
  RegExp kababRE = RegExp(r'[A-Z]');
  return str.replaceAllMapped(kababRE, (match) => '-${match[0].toLowerCase()}');
}

String camelize(String str) {
  RegExp kababRE = RegExp(r'-(\w)');
  return str.replaceAllMapped(kababRE, (match) {
    String subStr = match[0].substring(1);
    return subStr.isNotEmpty ? subStr.toUpperCase() : '';
  });
}

String standardizeNumber(double number) {
  return "${(number * 100000).round() / 100000}px";
}

String getLocalName(String name) {
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
      return name.toLowerCase();
    default:
      return EMPTY_STRING;
  }
}

// Map initComputedStyle = {
//   'width': '300px',
//   'height': '150px',
//   'border-left-width': ZERO_PX,
//   'border-right-width': ZERO_PX,
//   'border-top-width': ZERO_PX,
//   'border-bottom-width': ZERO_PX,
//   'margin-left': ZERO_PX,
//   'margin-right': ZERO_PX,
//   'margin-top': ZERO_PX,
//   'margin-bottom': ZERO_PX,
//   'padding-left': ZERO_PX,
//   'padding-right': ZERO_PX,
//   'padding-top': ZERO_PX,
//   'padding-bottom': ZERO_PX,
//   'position': 'static'
// };

Map preComputedStyle = CSSInitialValues;

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

class debugInspector {
  int count = 0;
  Map<int, Node> nodeIdMap = {};
  Node rootNode;
  double viewportWidth;
  double viewportHeight;
  Map initComputedStyle = {};

  debugInspector(this.viewportWidth, this.viewportHeight, rootElement) {
    setRoot(rootElement);
    init();
  }

  void init() {
    preComputedStyle.forEach((key, value) {
      initComputedStyle[kebabize(key)] = value;
    });

    // create websocket server
    HttpServer.bind(InternetAddress.anyIPv4, 8082).then((HttpServer server) {
      print('DevTool WebSocket listening at -- ws://localhost:8082');
      print(
          'devtools://devtools/bundled/inspector.html?experiments=true&ws=localhost:8082');
      server.listen((HttpRequest request) {
        if (request.uri.path == '/json/version') {
          var data = {
            "Browser": KRAKEN_VERSION,
            "Protocol-Version": "1.3",
            "User-Agent":
                "Mozilla/5.  (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36",
            "V8-Version": "8.6.395.10",
            "WebKit-Version":
                "537.36 (@c69c33933bfc72a159aceb4aeca939eb0087416c)",
            "webSocketDebuggerUrl":
                "ws://localhost:8082/devtools/browser/e572c721-8673-4da0-b130-ca1ec836c2e4",
          };
          request.response.headers
            ..clear()
            ..contentType = ContentType.json
            ..contentLength = jsonEncode(data).length;
          request.response
            ..write(jsonEncode(data))
            ..close();
        } else if (request.uri.path == '/json') {
          var data = [
            {
              "description": "",
              "devtoolsFrontendUrl":
                  "/devtools/inspector.html?ws=localhost:9529/devtools/page/623CD514C0CC3E58B89816E29E9E3D0F",
              "id": "623CD514C0CC3E58B89816E29E9E3D0F",
              "title": "0.0.0.123",
              "type": "page",
              "url": "",
              "webSocketDebuggerUrl":
                  "ws://localhost:9529/devtools/page/623CD514C0CC3E58B89816E29E9E3D0F",
            }
          ];
          request.response.headers
            ..clear()
            ..contentType = ContentType.json
            ..contentLength = jsonEncode(data).length;
          request.response
            ..write(jsonEncode(data))
            ..close();
        } else if (request.headers['upgrade'] != null &&
            request.headers['upgrade'][0] == 'websocket') {
          WebSocketTransformer.upgrade(request).then((WebSocket ws) {
            ws.listen((message) {
              handleResponse(message, ws);
            });
          });
        } else {
          request.response.write('');
          request.response.statusCode = HttpStatus.ok;
          request.response.close();
        }
      }, onError: (error) => print(error));
    }, onError: (error) => print(error));
  }

  // handle devTool protocol methods
  void handleResponse(String message, WebSocket ws) {
    var data = jsonDecode(message);
    String result;
    switch (data['method']) {
      case 'DOM.getDocument':
        if (rootNode != null)
          result = jsonEncode({
            'id': data['id'],
            'result': {'root': getDocument()}
          });
        else {
          result = jsonEncode({'node': data['id'], 'result': {}});
        }
        ws.add(result);
        break;
      case 'DOM.requestChildNodes':
        var nodeId = data['params']['nodeId'];
        var children = [];
        nodeIdMap[nodeId].childNodes.forEach((node) {
          nodeIdMap[count] = node;
          children.add(nodeToMap(node, count++));
        });
        result = jsonEncode({
          'method': 'DOM.setChildNodes',
          'params': {
            'parentId': nodeId,
            'nodes': children,
          },
        });
        String response = jsonEncode({'id': data['id'], 'result': {}});
        ws.add(result);
        ws.add(response);
        break;
      case 'CSS.getMatchedStylesForNode':
        int nodeId = data['params']['nodeId'];
        String res = jsonEncode({
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
        break;
      case 'CSS.getComputedStyleForNode':
        int nodeId = data['params']['nodeId'];
        String res = jsonEncode({
          'id': data['id'],
          'result': {'computedStyle': getComputedStyle(nodeId)}
        });
        ws.add(res);
        break;
      case 'CSS.setStyleTexts':
        Map edits = data['params']['edits'][0];
        int styleSheetId = edits['styleSheetId'];
        String cssText = edits['text'];
        CSSParser cssParse = CSSParser(cssText);
        List<Map<String, dynamic>> PropertiesList = cssParse.declarations();
        var node = nodeIdMap[styleSheetId];
        List cssProperties = [];
        PropertiesList.forEach((element) {
          if (element is Map) {
            String key = element['property'];
            String camelKey = camelize(key);
            String value = element['value'];
            bool disable = element['disabled'] ?? false;

            if (node is Element) {
              if (disable) {
                node.setStyle(camelKey, '');
              } else {
                node.setStyle(camelKey, value);
              }
            }
            cssProperties.add({
              'name': key,
              'value': value,
              'disabled': disable,
              'range': element['range'],
            });
          }
        });

        ws.add(jsonEncode({
          'id': data['id'],
          'result': {
            'styles': [getInlineStyle(styleSheetId)]
          }
        }));

        ws.add(jsonEncode({
          'method': 'CSS.styleSheetChanged',
          'params': {'styleSheetId': styleSheetId}
        }));

        ws.add(jsonEncode({
          'method': 'DOM.inlineStyleInvalidated	',
          'params': {
            'nodeId': [styleSheetId]
          }
        }));

        break;

      case 'CSS.getInlineStylesForNode':
        var nodeId = data['params']['nodeId'];
        ws.add(jsonEncode({
          'id': data['id'],
          'result': {'inlineStyle': getInlineStyle(nodeId)}
        }));
        break;

      default:
        result = jsonEncode({'id': data['id'], 'result': {}});
        ws.add(result);
        break;
    }
  }

  // transfer node to protocol standard format
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

    if (node is Element && node.style.length > 0) {
      CSSStyleDeclaration style = node.style;
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

    if (node is Element) {
      CSSStyleDeclaration style = node.style;
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

      Map rect = jsonDecode(node.getBoundingClientRect());
      rect.forEach((key, value) {
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
