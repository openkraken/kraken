/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/inspector.dart';

const String CSS_GET_COMPUTED_STYLE_FOR_NODE = 'CSS.getComputedStyleForNode';
const String CSS_GET_INLINE_STYLES_FOR_NODE = 'CSS.getInlineStylesForNode';
const String CSS_GET_MATCHED_STYLES_FOR_NODE = 'CSS.getMatchedStylesForNode';
const String CSS_STYLE_SHEET_CHANGED = 'CSS.styleSheetChanged';
const String CSS_SET_STYLE_TEXTS = 'CSS.setStyleTexts';

const String _borderTopWidth = 'border-top-width';
const String _borderRigthWidth = 'border-right-width';
const String _borderBottomWidth = 'border-bottom-width';
const String _borderLeftWidth = 'border-left-width';

const String ZERO_PX = '0px';

String kebabize(String str) {
  RegExp kababReg = RegExp(r'[A-Z]');
  return str.replaceAllMapped(kababReg, (match) => '-${match[0].toLowerCase()}');
}

String camelize(String str) {
  RegExp camelizeReg = RegExp(r'-(\w)');
  return str.replaceAllMapped(camelizeReg, (match) {
    String subStr = match[0].substring(1);
    return subStr.isNotEmpty ? subStr.toUpperCase() : '';
  });
}

class InspectorCSSAgent {
  InspectorDOMAgent _domAgent;
  int count = 0;
  Map<String, InspectorCSSStyle> idToInspectorCSSStyle = {};
  Map<InspectorCSSStyle, int> inspectorCSSStyleToTargetId = {};

  InspectorCSSAgent(this._domAgent);

  ResponseState onRequest(
      Map<String, dynamic> params, String method, InspectorData protocolData) {
    switch (method) {
      case CSS_GET_MATCHED_STYLES_FOR_NODE:
        int nodeId = params['nodeId'];
        return getMatchedStylesForNode(protocolData, nodeId);
        break;
      case CSS_GET_COMPUTED_STYLE_FOR_NODE:
        int nodeId = params['nodeId'];
        return getComputedStyleForNode(protocolData, nodeId);
        break;
      case CSS_GET_INLINE_STYLES_FOR_NODE:
        int nodeId = params['nodeId'];
        return getInlineStylesForNode(protocolData, nodeId);
        break;
      case CSS_SET_STYLE_TEXTS:
        return setStyleTexts(protocolData, params);
        break;
    }

    return ResponseState.Success;
  }

  ResponseState setStyleTexts(InspectorData inspectorData, Map<String, dynamic> params) {
    assert(params['edits'] is List<dynamic>);

    List<dynamic> edits = params['edits'];

    List<InspectorCSSStyle> styles = [];

    for (int i = 0; i < edits.length; i++) {
      Map<String, dynamic> edit = edits[i];
      assert(edit['styleSheetId'] is String);
      assert(edit['range'] is Map<String, dynamic>);
      assert(edit['text'] is String);

      String styleSheetId = edit['styleSheetId'];
      Map<String, dynamic> range = edit['range'];
      String cssText = edit['text'];

      InspectorCSSStyle cssStyle = setStyleText(styleSheetId, cssText, range);

      if (cssStyle == null) {
        continue;
      }

      styles.add(cssStyle);
    }

    inspectorData.setResult('styles', styles);

    return ResponseState.Success;
  }

  InspectorCSSStyle setStyleText(
      String styleSheetId, String cssText, Map<String, dynamic> range) {
    InspectorCSSStyle cssStyle = idToInspectorCSSStyle[styleSheetId];

    if (cssStyle == null) return null;

    int targetId = inspectorCSSStyleToTargetId[cssStyle];

    if (targetId == null) return null;

    Element element = _domAgent.getElementById(targetId);

    if (element == null) return null;

    CSSTextParser cssParse = CSSTextParser(cssText);
    List<CSSProperty> propertiesList = cssParse.declarations();

    propertiesList.forEach((property) {
      String propertyName = property.getName();
      String propertyValue = property.getValue();
      bool propertyDisabled = property.getDisabled() ?? false;
      propertyName = camelize(propertyName);

      if (propertyDisabled) {
        element.setStyle(propertyName, '');
      } else {
        element.setStyle(propertyName, propertyValue);
      }
    });

    SourceRange sourceRange = SourceRange(endColumn: cssText.length);

    InspectorCSSStyle style = InspectorCSSStyle()
      ..setCssProperties(propertiesList)
      ..setStyleSheetId(styleSheetId)
      ..setCssText(cssText)
      ..setRange(sourceRange);

    return style;
  }

  ResponseState getMatchedStylesForNode(InspectorData jsonData, int nodeId) {
    ResponseState inlineStyleState = getInlineStylesForNode(jsonData, nodeId);

    if (inlineStyleState != ResponseState.Success) {
      return ResponseState.Error;
    }

    return ResponseState.Success;
  }

  ResponseState getInlineStylesForNode(InspectorData jsonData, int nodeId) {
    InspectorDOMNode domNode = _domAgent.getDOMNode(nodeId);

    if (domNode == null) return ResponseState.Error;

    int backendNodeId = domNode.getBackendNodeId();
    Element element = _domAgent.getElementById(backendNodeId);

    if (element == null) return ResponseState.Error;

    InspectorCSSStyle inlineStyle = buildObjectForStyle(element.style);

    inspectorCSSStyleToTargetId[inlineStyle] = backendNodeId;

    jsonData.setResult('inlineStyle', inlineStyle);
    return ResponseState.Success;
  }

  ResponseState getComputedStyleForNode(InspectorData jsonData, int nodeId) {
    InspectorDOMNode domNode = _domAgent.getDOMNode(nodeId);

    if (domNode == null) return ResponseState.Error;

    int backEndNodeId = domNode.getBackendNodeId();
    Element element = _domAgent.getElementById(backEndNodeId);

    if (element == null) return ResponseState.Error;

    InspectorCSSComputedStyle computedStyle =
        buildArrayForComputedStyle(element);

    jsonData.setResult('computedStyle', computedStyle);

    return ResponseState.Success;
  }

  InspectorCSSStyle buildObjectForStyle(CSSStyleDeclaration style) {
    List<CSSProperty> properties = [];
    String cssText = '';

    for (int i = 0; i < style.length; i++) {
      if (cssText.isNotEmpty) cssText += ' ';

      String propertyName = style.item(i);
      String propertyValue = style.getPropertyValue(propertyName);
      propertyName = kebabize(propertyName);
      String propertyText = '${propertyName}: ${propertyValue};';

      CSSProperty property = CSSProperty();
      SourceRange range = SourceRange();

      int startColumn = cssText.length;
      int endColumn = startColumn + propertyText.length;

      // Set sourceRange item
      range.setStartColumn(startColumn);
      range.setEndColumn(endColumn);

      // Set CSSProperty item
      property.setName(propertyName);
      property.setValue(propertyValue);
      property.setText(propertyText);
      property.setRange(range);

      cssText += propertyText;

      properties.add(property);
    }

    SourceRange range = SourceRange(endColumn: cssText.length);

    String styleSheetId = '${++count}';
    InspectorCSSStyle inlineStyle = InspectorCSSStyle()
      ..setStyleSheetId(styleSheetId)
      ..setCssProperties(properties)
      ..setRange(range)
      ..setCssText(cssText);

    idToInspectorCSSStyle[styleSheetId] = inlineStyle;

    return inlineStyle;
  }

  InspectorCSSComputedStyle buildArrayForComputedStyle(Element element) {
    InspectorCSSComputedStyle computedStyle = InspectorCSSComputedStyle();
    CSSStyleDeclaration style = element.style;

    computedStyle.setStyle('display', element.defaultDisplay);

    for (int i = 0; i < style.length; i++) {
      String propertyName = style.item(i);
      String propertyValue = style.getPropertyValue(propertyName);
      propertyName = kebabize(propertyName);

      if (CSSLength.isLength(propertyValue)) {
        propertyValue = '${CSSLength.toDisplayPortValue(propertyValue)}px';
      }

      computedStyle.setStyle(propertyName, propertyValue);
    }

    if (style[BORDER_TOP_STYLE].isEmpty || style[BORDER_TOP_STYLE] == NONE) {
      computedStyle[_borderTopWidth] = ZERO_PX;
    }

    if (style[BORDER_RIGHT_STYLE].isEmpty ||
        style[BORDER_RIGHT_STYLE] == NONE) {
      computedStyle[_borderRigthWidth] = ZERO_PX;
    }

    if (style[BORDER_BOTTOM_STYLE].isEmpty ||
        style[BORDER_RIGHT_STYLE] == NONE) {
      computedStyle[_borderBottomWidth] = ZERO_PX;
    }

    if (style[BORDER_LEFT_STYLE].isEmpty || style[BORDER_LEFT_STYLE] == NONE) {
      computedStyle[_borderLeftWidth] = ZERO_PX;
    }

    Map<String, dynamic> boundingClientRect =
        jsonDecode(element.getBoundingClientRect());

    boundingClientRect.forEach((key, value) {
      computedStyle.setStyle(key, '${value}px');
    });

    return computedStyle;
  }
}


/// Inspector CSS Style representation.
class InspectorCSSStyle {
  /// Optional: The css style sheet identifier.
  String styleSheetId;

  /// CSS properties in the style.
  List<CSSProperty> cssProperties = [];

  /// Computed values for all shorthands found in the style.
  List<ShorthandEntry> shorthandEntries = [];

  /// Optional: style declaration text.
  String cssText = '';

  /// Optional: style declaration range.
  SourceRange range = SourceRange();

  void setStyleSheetId(String value) {
    styleSheetId = value;
  }

  void setCssProperties(List<CSSProperty> value) {
    cssProperties = value;
  }

  void setShorthandEntry(List<ShorthandEntry> value) {
    shorthandEntries = value;
  }

  void setRange(SourceRange value) {
    range = value;
  }

  void setCssText(String value) {
    cssText = value;
  }

  Map<String, dynamic> toJson() {
    return {
      if (styleSheetId != null) 'styleSheetId': styleSheetId,
      'cssProperties':
          cssProperties.map((cssProperty) => cssProperty.toJson()).toList(),
      'shorthandEntries': shorthandEntries
          .map((shorthandEntry) => shorthandEntry.toJson())
          .toList(),
      'cssText': cssText,
      'range': range.toJson(),
    };
  }
}

class InspectorCSSComputedStyle {
  Map<String, String> properties = {};

  InspectorCSSComputedStyle() {
    CSSInitialValues.forEach((key, value) {
      String kebabizedKey = kebabize(key);
      String handledValue = value == '0' ? '0px' : value;
      properties[kebabizedKey] = handledValue;
    });
  }

  void setStyle(String key, String value) {
    properties[key] = value;
  }

  String getStyle(String key) {
    return properties[key];
  }

  bool hasStyle(String key) {
    return properties[key] == null;
  }

  List<Map<String, String>> toJson() {
    List<Map<String, String>> styles = [];

    properties.forEach((key, value) {
      styles.add({'name': key, 'value': value});
    });

    return styles;
  }

  /// Override [] and []= operator to get/set style properties.
  operator [](String key) => getStyle(key);
  operator []=(String key, value) {
    setStyle(key, value);
  }
}
