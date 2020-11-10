/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/inspector.dart';

final RegExp _spaceRegExp = RegExp(r'^[\s\u21b5]*');
final RegExp _newlineRegExp = RegExp(r'[\n\u21b5]');
final RegExp _propertyNameRegExp = RegExp(r'^(\*?[-#\/\*\\\w]+(\[[0-9a-z_-]+\])?)\s*');
final RegExp _colonRegExp = RegExp(r'^:\s*');
final RegExp _propertyValueRegExp = RegExp(r'''^((?:'(?:\\'|.)*?'|"(?:\\"|.)*?"|\([^\)]*?\)|[^};])+)''');
final RegExp _semicolonRegExp = RegExp(r'^[;\s]*');
final RegExp _commentStartRegExp = RegExp(r'^\/\*\s');
final RegExp _commentEndRegExp = RegExp(r'^\*\/');

class CSSTextParser {
  int line = 0;
  int column = 0;
  String cssText = '';
  Map<String, dynamic> declaration = {};

  CSSTextParser(this.cssText);

  List<CSSProperty> declarations() {
    List<CSSProperty> decs = [];
    match(_spaceRegExp);

    CSSProperty commentDeclaration = getCommentDeclaration();

    if (commentDeclaration != null) {
      decs.add(commentDeclaration);
      match(_spaceRegExp);
    }

    CSSProperty cssProperty = getDeclaration();

    while (cssProperty != null) {
      decs.add(cssProperty);
      match(_spaceRegExp);

      commentDeclaration = getCommentDeclaration();
      if (commentDeclaration != null) {
        decs.add(commentDeclaration);
        match(_spaceRegExp);
      }

      cssProperty = getDeclaration();
    }

    return decs;
  }

  CSSProperty getCommentDeclaration() {
    SourceRange range = SourceRange()
      ..setStartLine(line)
      ..setStartColumn(column);

    if (cssText.length < 2 || (cssText[0] != '/' && cssText[1] != '*'))
      return null;

    match(_commentStartRegExp);

    CSSProperty cssProperty = getDeclaration();

    match(_commentEndRegExp);

    range.setEndLine(line);
    range.setEndColumn(column);

    cssProperty
      ..setRange(range)
      ..setDisabled(true)
      ..setText('/* ${cssProperty.getName()}: ${cssProperty.getValue()}; */');

    return cssProperty;
  }

  CSSProperty getDeclaration() {
    SourceRange range = SourceRange();
    range.setStartLine(line);
    range.setStartColumn(column);

    var prop = match(_propertyNameRegExp);
    prop = trim(prop);

    var colon = match(_colonRegExp);

    if (colon.isEmpty) return null;

    var value = match(_propertyValueRegExp);
    value = trim(value);

    match(_semicolonRegExp);

    range.setEndLine(line);
    range.setEndColumn(column);

    CSSProperty cssProperty = CSSProperty()
      ..setRange(range)
      ..setName(prop)
      ..setValue(value)
      ..setDisabled(false)
      ..setText('$prop: $value;');

    return cssProperty;
  }

  void updatePosition(String str) {
    var newLines = _newlineRegExp.allMatches(str);
    if (newLines.isNotEmpty) {
      line += newLines.length;
      column += str.length - newLines.last.end;
    } else {
      column += str.length;
    }
  }

  String match(RegExp re) {
    var str = re.stringMatch(cssText);
    if (str == null || str.isEmpty) return '';
    updatePosition(str);
    cssText = cssText.substring(str.length);
    return str;
  }
}

final RegExp _trimRegExp = RegExp(r'^\s+|\s+$');

// trim string
String trim(String str) {
  if (str == null || str.isEmpty) {
    return '';
  }

  return str.replaceAll(_trimRegExp, '');
}


/// Inspector CSS property declaration data.
class CSSProperty implements JSONEncodable {
  /// The property name.
  String name = '';

  /// The property value.
  String value = '';

  /// Optional: whether the property has !important annotaion
  bool important;

  /// Optional: whether the property is implicit.
  bool implicit;

  /// Optional: the full property text.
  String text;

  /// Optional: whether the property is understood by the browser.
  bool parsedOk;

  /// Optional: whether the property is disabled by the user.
  bool disabled;

  /// Optional: the entire property range.
  SourceRange range;

  void setName(String value) {
    name = value;
  }

  String getName() {
    return name;
  }

  void setValue(String value) {
    this.value = value;
  }

  String getValue() {
    return value;
  }

  void setParsedOk(bool value) {
    parsedOk = value;
  }

  void setText(String value) {
    text = value;
  }

  void setImportant(bool value) {
    important = value;
  }

  void setImplicit(bool value) {
    implicit = value;
  }

  void setDisabled(bool value) {
    disabled = value;
  }

  bool getDisabled() {
    return disabled;
  }

  void setRange(SourceRange value) {
    range = value;
  }

  SourceRange getRange() {
    return range;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      if (important != null) 'important': important,
      if (implicit != null) 'implicit': implicit,
      if (text != null) 'text': text,
      if (parsedOk != null) 'parsedOk': parsedOk,
      if (disabled != null) 'disabled': disabled,
      if (range != null) 'range': range.toJson()
    };
  }
}


/// Text range within a resource. All number are zero-based.
class SourceRange implements JSONEncodable {
  /// Start line of range.
  int startLine;

  /// Start column of range (inclusive).
  int startColumn;

  /// End line of range.
  int endLine;

  /// End column of range (exclusive).
  int endColumn;

  SourceRange(
      {this.startLine = 0,
        this.startColumn = 0,
        this.endLine = 0,
        this.endColumn = 0});

  SourceRange.fromJson(Map<String, dynamic> json) {
    startLine = json['startLine'];
    startColumn = json['startColumn'];
    endColumn = json['endColumn'];
    endLine = json['endLine'];
  }

  void setStartLine(int value) {
    startLine = value;
  }

  void setStartColumn(int value) {
    startColumn = value;
  }

  void setEndLine(int value) {
    endLine = value;
  }

  void setEndColumn(int value) {
    endColumn = value;
  }

  Map<String, int> toJson() {
    return {
      'startLine': startLine,
      'startColumn': startColumn,
      'endLine': endLine,
      'endColumn': endColumn
    };
  }
}

/// ShortHand Entry for property.
class ShorthandEntry implements JSONEncodable {
  String name;
  String value;
  bool important;

  ShorthandEntry(this.name, this.value, {this.important});

  Map<String, dynamic> toJson() {
    return {
      name: 'name',
      value: 'name',
      if (important != null) 'important': important
    };
  }
}
