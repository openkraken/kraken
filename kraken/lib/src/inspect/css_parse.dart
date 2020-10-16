/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

final RegExp _spaceRegExp = RegExp(r'^[\s\u21b5]*');
final RegExp _newlineRegExp = RegExp(r'[\n\u21b5]');
final RegExp _propertyNameRegExp =
    RegExp(r'^(\*?[-#\/\*\\\w]+(\[[0-9a-z_-]+\])?)\s*');
final RegExp _colonRegExp = RegExp(r'^:\s*');
final RegExp _propertyValueRegExp =
    RegExp(r'''^((?:'(?:\\'|.)*?'|"(?:\\"|.)*?"|\([^\)]*?\)|[^};])+)''');
final RegExp _semicolonRegExp = RegExp(r'^[;\s]*');
final RegExp _commentStartRegExp = RegExp(r'^\/\*\s');
final RegExp _commentEndRegExp = RegExp(r'^\*\/');

class CSSParser {
  int line = 0;
  int column = 0;
  String cssText = '';
  Map<String, dynamic> declaration = {};

  CSSParser(this.cssText);

  List<Map<String, dynamic>> declarations() {
    List<Map<String, dynamic>> decs = [];
    match(_spaceRegExp);

    if (hasCommentDeclaration()) {
      decs.add(declaration);
      match(_spaceRegExp);
    }

    while (hasDeclaration()) {
      decs.add(declaration);
      match(_spaceRegExp);
      if (hasCommentDeclaration()) {
        decs.add(declaration);
        match(_spaceRegExp);
      }
    }

    return decs;
  }

  bool hasCommentDeclaration() {
    var startOffset = {'startLine': line, 'startColumn': column};

    if (cssText.length < 2 || (cssText[0] != '/' && cssText[1] != '*'))
      return false;

    match(_commentStartRegExp);

    hasDeclaration();

    match(_commentEndRegExp);

    declaration['range'] = {
      ...startOffset,
      'endLine': line,
      'endColumn': column
    };
    declaration['disabled'] = true;

    return true;
  }

  bool hasDeclaration() {
    var startOffset = {'startLine': line, 'startColumn': column};
    var prop = match(_propertyNameRegExp);
    prop = trim(prop);

    var colon = match(_colonRegExp);

    if (colon.isEmpty) return false;

    var value = match(_propertyValueRegExp);
    value = trim(value);

    match(_semicolonRegExp);

    declaration = {
      'type': 'declaration',
      'property': prop,
      'value': value,
      'range': {...startOffset, 'endLine': line, 'endColumn': column},
      'disabled': false,
    };

    return true;
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
