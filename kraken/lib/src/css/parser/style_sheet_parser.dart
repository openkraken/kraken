/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/css.dart';

const int _BEFORE_SELECTOR = 0;
const int _SELECTOR = 1;
const int _BEFORE_NAME = 2;
const int _NAME = 3;
const int _VALUE = 4;

final RegExp _classSelectorRegExp = RegExp(r'^\s*.[-_a-zA-Z][-_a-zA-Z0-9]*\s*$');

class CSSStyleSheetParser {
  static List<CSSRule> parse(String sheetText) {
    final List<CSSRule> rules = <CSSRule>[];
    StringBuffer buffer = StringBuffer();
    int state = _BEFORE_SELECTOR;
    for (int pos = 0, length = sheetText.length; pos < length; pos++) {
      int c = sheetText.codeUnitAt(pos);
      switch(c) {
        case DOT_CODE:
          // Current only support single class selector: `.red`.
          int code = sheetText.codeUnitAt(pos + 1);
          // `.` must followed by `-`, `_`, `a-z`, `A-Z`.
          if (state == _BEFORE_SELECTOR && (code == 45 || code == 95 || (code < 123 && code > 96) || (code < 91 && code > 64))) {
            state = _SELECTOR;
            buffer.writeCharCode(c);
          } else if (state != _BEFORE_SELECTOR) {
            buffer.writeCharCode(c);
          }
          break;
        case SPACE_CODE:
        case TAB_CODE:
        case CR_CODE:
        case FEED_CODE:
        case NEWLINE_CODE:
          if (state != _BEFORE_SELECTOR && (state == _SELECTOR || state == _VALUE) && pos > 0) {
            // Squash 2 or more white-spaces in the row into 1 space.
            switch (sheetText.codeUnitAt(pos - 1)) {
              case SPACE_CODE:
              case TAB_CODE:
              case CR_CODE:
              case FEED_CODE:
              case NEWLINE_CODE:
                break;
              default:
                buffer.writeCharCode(SPACE_CODE);
                break;
            }
          }
          break;
        case SEMICOLON_CODE:
          if (state != _BEFORE_SELECTOR && state == _VALUE || state == _NAME) {
            if (state == _NAME) {
              state = _BEFORE_NAME;
            }
            buffer.writeCharCode(c);
          }
          break;
        case OPEN_CURLY_CODE:
          if (state == _SELECTOR) {
            String selector = buffer.toString();
            // Only support single class selector now.
            state = _classSelectorRegExp.hasMatch(selector) ? _BEFORE_NAME : _BEFORE_SELECTOR;
            if (state == _BEFORE_SELECTOR) {
              buffer.clear();
            }
          }
          if (state != _BEFORE_SELECTOR) {
            buffer.writeCharCode(c);
          }
          break;
         case COLON_CODE:
          if (state == _NAME) {
            state = _VALUE;
          }
          if (state != _BEFORE_SELECTOR) {
            buffer.writeCharCode(c);
          }
          break;
        case CLOSE_CURLY_CODE:
          if (state == _BEFORE_SELECTOR) break;
          if (state == _VALUE || state == _BEFORE_NAME) {
            buffer.writeCharCode(c);
            String ruleText = buffer.toString();
            CSSStyleRule? styleRule = CSSStyleRuleParser.parse(ruleText);
            if (styleRule != null) {
              rules.add(styleRule);
            }
          } else if (state == _NAME){
            // `.foo { .x {}; color: red }`
            buffer.writeCharCode(c);
          }

          if (state != _NAME) {
            buffer.clear();
            state = _BEFORE_SELECTOR;
          }
          break;
        default:
          if (state == _BEFORE_SELECTOR) break;
          buffer.writeCharCode(c);
          if (state == _BEFORE_NAME) {
            state = _NAME;
          }
      }
    }
    return rules;
  }
}
