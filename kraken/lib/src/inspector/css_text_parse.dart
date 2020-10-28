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
