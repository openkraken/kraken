/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/devtools.dart';
import 'package:kraken/dom.dart';

const int INLINED_STYLESHEET_ID = 1;
const String ZERO_PX = '0px';
RegExp _kebabCaseReg = RegExp(r'[A-Z]');
RegExp _camelCaseReg = RegExp(r'-(\w)');

class InspectCSSModule extends UIInspectorModule {
  Document get document => devtoolsService.controller!.view.document;
  InspectCSSModule(ChromeDevToolsService devtoolsService): super(devtoolsService);

  @override
  String get name => 'CSS';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'getMatchedStylesForNode':
        handleGetMatchedStylesForNode(id, params!);
        break;
      case 'getComputedStyleForNode':
        handleGetComputedStyleForNode(id, params!);
        break;
      case 'getInlineStylesForNode':
        handleGetInlineStylesForNode(id, params!);
        break;
      case 'setStyleTexts':
        handleSetStyleTexts(id, params!);
        break;
    }
  }

  void handleGetMatchedStylesForNode(int? id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    Element? element = document.controller.view.getEventTargetById<Element>(nodeId);
    if (element != null) {
      MatchedStyles matchedStyles = MatchedStyles(
        inlineStyle: buildInlineStyle(element),
      );
      sendToFrontend(id, matchedStyles);
    }
  }

  void handleGetComputedStyleForNode(int? id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    Element? element = document.controller.view.getEventTargetById<Element>(nodeId);

    if (element != null) {
      ComputedStyle computedStyle = ComputedStyle(
        computedStyle: buildComputedStyle(element),
      );
      sendToFrontend(id, computedStyle);
    }
  }

  // Returns the styles defined inline (explicitly in the "style" attribute and
  // implicitly, using DOM attributes) for a DOM node identified by nodeId.
  void handleGetInlineStylesForNode(int? id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    Element? element = document.controller.view.getEventTargetById<Element>(nodeId);

    if (element != null) {
      InlinedStyle inlinedStyle = InlinedStyle(
        inlineStyle: buildInlineStyle(element),
        attributesStyle: buildAttributesStyle(element.properties),
      );
      sendToFrontend(id, inlinedStyle);
    }
  }

  void handleSetStyleTexts(int? id, Map<String, dynamic> params) {
    List edits = params['edits'];
    List<CSSStyle?> styles = [];

    // @TODO: diff the inline style edits.
    // @TODO: support comments for inline style.
    for (Map<String, dynamic> edit in edits) {
      // Use styleSheetId to identity element.
      int nodeId = edit['styleSheetId'];
      String text = edit['text'] ?? '';
      List<String> texts = text.split(';');
      Element? element = document.controller.view.getEventTargetById<Element>(nodeId);
      if (element != null) {
        for (String kv in texts) {
          kv = kv.trim();
          List<String> _kv = kv.split(':');
          if (_kv.length == 2) {
            String name = _kv[0].trim();
            String value = _kv[1].trim();
            element.setInlineStyle(_camelize(name), value);
          }
        }
        styles.add(buildInlineStyle(element));
      } else {
        styles.add(null);
      }
    }

    sendToFrontend(id, JSONEncodableMap({
      'styles': styles,
    }));
  }

  static CSSStyle? buildInlineStyle(Element element) {
    List<CSSProperty> cssProperties = [];
    String cssText = '';
    element.inlineStyle.forEach((key, value) {
      String kebabName = _kebabize(key);
      String propertyValue = value.toString();
      String _cssText = '$kebabName: $propertyValue';
      CSSProperty cssProperty = CSSProperty(
        name: kebabName,
        value: value,
        range: SourceRange(
          startLine: 0,
          startColumn: cssText.length,
          endLine: 0,
          endColumn: cssText.length + _cssText.length + 1,
        ),
      );
      cssText += '$_cssText; ';
      cssProperties.add(cssProperty);
    });

    return CSSStyle(
      // Absent for user agent stylesheet and user-specified stylesheet rules.
      // Use hash code id to identity which element the rule belongs to.
      styleSheetId: element.ownerDocument.controller.view.getTargetIdByEventTarget(element),
      cssProperties: cssProperties,
      shorthandEntries: <ShorthandEntry>[],
      cssText: cssText,
      range: SourceRange(startLine: 0, startColumn: 0, endLine: 0, endColumn: cssText.length)
    );
  }

  static String resolveCSSDisplayString(CSSDisplay display) {
    switch (display) {
      case CSSDisplay.none:
        return 'none';
      case CSSDisplay.sliver:
        return 'sliver';
      case CSSDisplay.block:
        return 'block';
      case CSSDisplay.inlineBlock:
        return 'inline-block';
      case CSSDisplay.flex:
        return 'flex';
      case CSSDisplay.inlineFlex:
        return 'inline-flex';
      case CSSDisplay.inline:
      default:
        return 'inline';
    }
  }

  static String _resolveCSSLengthType(CSSLengthType type) {
    switch (type) {
      case CSSLengthType.PX:
        return 'px';
      case CSSLengthType.EM:
        return 'em';
      case CSSLengthType.REM:
        return 'rem';
      case CSSLengthType.VH:
        return 'vh';
      case CSSLengthType.VW:
        return 'vw';
      case CSSLengthType.VMIN:
        return 'vmin';
      case CSSLengthType.VMAX:
        return 'vmax';
      case CSSLengthType.PERCENTAGE:
        return '%';
      case CSSLengthType.UNKNOWN:
        return '';
      case CSSLengthType.AUTO:
        return 'auto';
      case CSSLengthType.NONE:
        return 'none';
      case CSSLengthType.NORMAL:
        return 'normal';
      case CSSLengthType.INITIAL:
        return 'initial';
    }
  }

  static List<CSSComputedStyleProperty> buildComputedStyle(Element element) {
    List<CSSComputedStyleProperty> computedStyle = [];
    CSSStyleDeclaration style = element.style;
    RenderStyle? renderStyle = element.renderStyle;

    for (int i = 0; i < style.length; i++) {
      String propertyName = style.item(i);
      String propertyValue = style.getPropertyValue(propertyName);
      propertyName = _kebabize(propertyName);

      if (CSSLength.isLength(propertyValue)) {
        CSSLengthValue? len = CSSLength.resolveLength(
          propertyValue,
          renderStyle,
          propertyName,
        );

        propertyValue = len == null ? '0' : '${len.computedValue}${_resolveCSSLengthType(len.type)}';
      }

      if (propertyName == DISPLAY) {
        propertyValue = resolveCSSDisplayString(element.renderStyle.display);
      }

      computedStyle.add(CSSComputedStyleProperty(name: propertyName, value: propertyValue));
    }

    if (!style.contains(BORDER_TOP_STYLE)) {
      computedStyle.add(CSSComputedStyleProperty(name: _kebabize(BORDER_TOP_STYLE), value: ZERO_PX));
    }
    if (!style.contains(BORDER_RIGHT_STYLE)) {
      computedStyle.add(CSSComputedStyleProperty(name: _kebabize(BORDER_RIGHT_STYLE), value: ZERO_PX));
    }
    if (!style.contains(BORDER_BOTTOM_STYLE)) {
      computedStyle.add(CSSComputedStyleProperty(name: _kebabize(BORDER_BOTTOM_STYLE), value: ZERO_PX));
    }
    if (!style.contains(BORDER_LEFT_STYLE)) {
      computedStyle.add(CSSComputedStyleProperty(name: _kebabize(BORDER_LEFT_STYLE), value: ZERO_PX));
    }

    // Calc computed size.
    Map<String, dynamic> boundingClientRect = element.boundingClientRect.toJSON();
    boundingClientRect.forEach((String name, value) {
      computedStyle.add(CSSComputedStyleProperty(name: name, value: '${value}px'));
    });

    return computedStyle;
  }

  // Kraken not supports attribute style for now.
  static CSSStyle? buildAttributesStyle(Map<String, dynamic> properties) {
    return null;
  }
}

class MatchedStyles extends JSONEncodable {

  MatchedStyles({
    this.inlineStyle,
    this.attributesStyle,
    this.matchedCSSRules,
    this.pseudoElements,
    this.inherited,
    this.cssKeyframesRules,
  });

  CSSStyle? inlineStyle;
  CSSStyle? attributesStyle;
  List<RuleMatch>? matchedCSSRules;
  List<PseudoElementMatches>? pseudoElements;
  List<InheritedStyleEntry>? inherited;
  List<CSSKeyframesRule>? cssKeyframesRules;

  @override
  Map toJson() {
    return {
      if (inlineStyle != null) 'inlineStyle': inlineStyle,
      if (attributesStyle != null) 'attributesStyle': attributesStyle,
      if (matchedCSSRules != null) 'matchedCSSRules': matchedCSSRules,
      if (pseudoElements != null) 'pseudoElements': pseudoElements,
      if (inherited != null) 'inherited': inherited,
      if (cssKeyframesRules != null) 'cssKeyframesRules': cssKeyframesRules,
    };
  }
}

class CSSStyle extends JSONEncodable {
  int? styleSheetId;
  List<CSSProperty> cssProperties;
  List<ShorthandEntry> shorthandEntries;
  String? cssText;
  SourceRange? range;

  CSSStyle({
    this.styleSheetId,
    required this.cssProperties,
    required this.shorthandEntries,
    this.cssText,
    this.range,
  });

  @override
  Map toJson() {
    return {
      if (styleSheetId != null) 'styleSheetId': styleSheetId,
      'cssProperties': cssProperties,
      'shorthandEntries': shorthandEntries,
      if (cssText != null) 'cssText': cssText,
      if (range != null) 'range': range,
    };
  }
}

class RuleMatch extends JSONEncodable {
  @override
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class PseudoElementMatches extends JSONEncodable {
  @override
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class InheritedStyleEntry extends JSONEncodable {
  @override
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class CSSKeyframesRule extends JSONEncodable {
  @override
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class CSSProperty extends JSONEncodable {
  String name;
  String value;
  bool important;
  bool implicit;
  String? text;
  bool parsedOk;
  bool? disabled;
  SourceRange? range;

  CSSProperty({
    required this.name,
    required this.value,
    this.important = false,
    this.implicit = false,
    this.text,
    this.parsedOk = true,
    this.disabled,
    this.range,
  });

  @override
  Map toJson() {
    return {
      'name': name,
      'value': value,
      'important': important,
      'implicit': implicit,
      'text': text,
      'parsedOk': parsedOk,
      if (disabled != null) 'disabled': disabled,
      if (range != null) 'range': range,
    };
  }
}

class SourceRange extends JSONEncodable {
  int startLine;
  int startColumn;
  int endLine;
  int endColumn;

  SourceRange({
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });

  @override
  Map toJson() {
    return {
      'startLine': startLine,
      'startColumn': startColumn,
      'endLine': endLine,
      'endColumn': endColumn,
    };
  }
}


class ShorthandEntry extends JSONEncodable {
  String name;
  String value;
  bool important;

  ShorthandEntry({
    required this.name,
    required this.value,
    this.important = false,
  });

  @override
  Map toJson() {
    return {
      'name': name,
      'value': value,
      'important': important,
    };
  }
}

/// https://chromedevtools.github.io/devtools-protocol/tot/CSS/#method-getComputedStyleForNode
class ComputedStyle extends JSONEncodable {
  List<CSSComputedStyleProperty> computedStyle;

  ComputedStyle({ required this.computedStyle });

  @override
  Map toJson() {
    return {
      'computedStyle': computedStyle,
    };
  }
}

/// https://chromedevtools.github.io/devtools-protocol/tot/CSS/#type-CSSComputedStyleProperty
class CSSComputedStyleProperty extends JSONEncodable {
  String name;
  String value;

  CSSComputedStyleProperty({ required this.name, required this.value });

  @override
  Map toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

class InlinedStyle extends JSONEncodable {
  CSSStyle? inlineStyle;
  CSSStyle? attributesStyle;

  InlinedStyle({ this.inlineStyle, this.attributesStyle });

  @override
  Map toJson() {
    return {
      if (inlineStyle != null) 'inlineStyle': inlineStyle,
      if (attributesStyle != null) 'attributesStyle': attributesStyle,
    };
  }
}

// aB to a-b
String _kebabize(String str) {
  return str.replaceAllMapped(_kebabCaseReg, (match) => '-${match[0]!.toLowerCase()}');
}

// a-b to aB
String _camelize(String str) {
  return str.replaceAllMapped(_camelCaseReg, (match) {
    String subStr = match[0]!.substring(1);
    return subStr.isNotEmpty ? subStr.toUpperCase() : '';
  });
}
