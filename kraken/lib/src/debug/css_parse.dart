class CssParse {
  var line = 0;
  var column = 0;
  String css = '';

  CssParse(this.css);

  RegExp WHITESPACE = RegExp(r'^[\s\u21b5]*');
  RegExp NEWLINE = RegExp(r'[\n\u21b5]');
  RegExp PROP = RegExp(r'^(\*?[-#\/\*\\\w]+(\[[0-9a-z_-]+\])?)\s*');
  RegExp COLON = RegExp(r'^:\s*');
  RegExp VALUE =
      RegExp(r'''^((?:'(?:\\'|.)*?'|"(?:\\"|.)*?"|\([^\)]*?\)|[^};])+)''');
  RegExp SEMICOLON = RegExp(r'^[;\s]*');
  RegExp COMMENT_LEFT = RegExp(r'^\/\*\s');
  RegExp COMMENT_RIGHT = RegExp(r'^\*\/');

  List declarations() {
    var decs = [];
    var dec;
    match(WHITESPACE);

    var comment = commentDeclaration();

    if (comment != false) {
      decs.add(comment);
      match(WHITESPACE);
    }

    while ((dec = declaration()) != false) {
      decs.add(dec);
      match(WHITESPACE);
      comment = commentDeclaration();
      if (comment != false) {
        decs.add(comment);
        match(WHITESPACE);
      }
    }

    return decs;
  }

  List getCssProperties() {
    return declarations();
  }

  Map getStartOffset() {
    return {'startLine': line, 'startColumn': column};
  }

  Map getEndOffset() {
    return {'endLine': line, 'endColumn': column};
  }

  dynamic commentDeclaration() {
    var startOffset = getStartOffset();

    if (css.length < 2 || (css[0] != '/' && css[1] != '*')) return false;

    match(COMMENT_LEFT);

    Map commentDec = declaration();

    match(COMMENT_RIGHT);

    var range = {...startOffset, 'endLine': line, 'endColumn': column};

    commentDec['range'] = range;
    commentDec['disabled'] = true;

    return commentDec;
  }

  dynamic declaration() {
    var startOffset = getStartOffset();
    var prop = match(PROP);
    prop = trim(prop);

    var colon = match(COLON);

    if (colon.isEmpty) return false;

    var value = match(VALUE);
    value = trim(value);

    match(SEMICOLON);

    var declaration = {
      'type': 'declaration',
      'property': prop,
      'value': value,
      'range': {...startOffset, 'endLine': line, 'endColumn': column}
    };

    return declaration;
  }

  void updatePosition(String str) {
    var newLines = NEWLINE.allMatches(str);
    if (newLines.isNotEmpty) {
      line += newLines.length;
      column += str.length - newLines.last.end;
    } else {
      column += str.length;
    }
  }

  String match(RegExp re) {
    var str = re.stringMatch(css);
    if (str == null || str.isEmpty) return '';
    updatePosition(str);
    css = css.substring(str.length);
    return str;
  }
}

// trim string
String trim(String str) {
  if (str == null || str.isEmpty) {
    return '';
  }

  return str.replaceAll(RegExp(r'^\s+|\s+$'), '');
}
