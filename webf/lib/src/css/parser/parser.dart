/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';

const int SLASH_CODE = 47; // /
const int NEWLINE_CODE = 10; // \n
const int SPACE_CODE = 32; // ' '
const int FEED_CODE = 12; // \f
const int TAB_CODE = 9; // \t
const int CR_CODE = 13; // \r
const int OPEN_CURLY_CODE = 123; // {
const int CLOSE_CURLY_CODE = 125; // }
const int SEMICOLON_CODE = 59; // ;
const int ASTERISK_CODE = 42; // *
const int COLON_CODE = 58; // :
const int OPEN_PARENTHESES_CODE = 40; // (
const int CLOSE_PARENTHESES_CODE = 41; // )
const int SINGLE_QUOTE_CODE = 39; // ';
const int DOUBLE_QUOTE_CODE = 34; // "
const int HYPHEN_CODE = 45; // -
const int AT_CODE = 64; // @
const int DOT_CODE = 46; // .

class CSSParser {
  static CSSRule? parseRule(String text, {CSSStyleSheet? parentStyleSheet}) {
    // TODO: parse other css rule
    CSSStyleRule? rule = CSSStyleRuleParser.parse(text);
    if (rule != null) {
      rule.parentStyleSheet = parentStyleSheet;
    }
    return rule;
  }

  static List<CSSRule> parseRules(String text, {CSSStyleSheet? parentStyleSheet}) {
    // TODO: should ingore style rule in at-rules
    return CSSStyleSheetParser.parse(text);
  }
}
