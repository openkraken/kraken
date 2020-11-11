import 'dart:convert';

import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:meta/meta.dart';
import '../module.dart';
import '../inspector.dart';

const int INLINED_STYLESHEET_ID = 1;

class InspectCSSModule extends InspectModule {
  final Inspector inspector;
  ElementManager get elementManager => inspector.elementManager;
  InspectCSSModule(this.inspector);

  @override
  String get name => 'CSS';

  @override
  void receiveFromBackend(int id, String method, Map<String, dynamic> params) {
    switch (method) {
      case 'getMatchedStylesForNode':
        handleGetMatchedStylesForNode(id, params);
        break;
    }
  }

  void handleGetMatchedStylesForNode(int id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    Element element = elementManager.getEventTargetByTargetId<Element>(nodeId);

    if (element != null) {
      MatchedStyles matchedStyles = MatchedStyles(
        inlineStyle: buildInlineStyle(element.style),
      );
      sendToBackend(id, matchedStyles);
    }
  }

  static CSSStyle buildInlineStyle(CSSStyleDeclaration style) {
    if (style == null) {
      return null;
    }

    List<CSSProperty> cssProperties = [];
    String cssText = '';
    for (int i = 0; i < style.length; i++) {
      String name = style.item(i);
      String kebabName = kebabize(name);
      String value = style.getPropertyValue(name);
      String _cssText = '$kebabName: $value';
      CSSProperty cssProperty = CSSProperty(
        name: kebabName,
        value: value,
        range: SourceRange(
          startLine: 0,
          startColumn: cssText.length,
          endLine: 0,
          endColumn: cssText.length + _cssText.length,
        ),
      );
      cssText += '$_cssText; ';
      cssProperties.add(cssProperty);
    }

    return CSSStyle(
      // Absent for user agent stylesheet and user-specified stylesheet rules.
      styleSheetId: INLINED_STYLESHEET_ID,
      cssProperties: cssProperties,
      shorthandEntries: <ShorthandEntry>[],
      cssText: cssText,
      range: SourceRange(startLine: 0, startColumn: 0, endLine: 0, endColumn: cssText.length)
    );
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

  CSSStyle inlineStyle;
  CSSStyle attributesStyle;
  List<RuleMatch> matchedCSSRules;
  List<PseudoElementMatches> pseudoElements;
  List<InheritedStyleEntry> inherited;
  List<CSSKeyframesRule> cssKeyframesRules;

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
  int styleSheetId;
  List<CSSProperty> cssProperties;
  List<ShorthandEntry> shorthandEntries;
  String cssText;
  SourceRange range;

  CSSStyle({
    this.styleSheetId,
    @required this.cssProperties,
    @required this.shorthandEntries,
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
  String text;
  bool parsedOk;
  bool disabled;
  SourceRange range;

  CSSProperty({
    @required this.name,
    @required this.value,
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
      if (important != null) 'important': important,
      if (implicit != null) 'implicit': implicit,
      if (text != null) 'text': text,
      if (parsedOk != null) 'parsedOk': parsedOk,
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
    @required this.startLine,
    @required this.startColumn,
    @required this.endLine,
    @required this.endColumn,
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
    @required this.name,
    @required this.value,
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

