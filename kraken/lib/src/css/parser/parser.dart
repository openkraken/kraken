/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';

const String _CLOSE_CURLY = '}';

class CSSParser {
  static CSSRule parseRule(String text) {
    // TODO: parse other css rule
    return CSSStyleRuleParser.parse(text);
  }

  static List<CSSRule> parseRules(String text) {
    List<CSSRule> rules = [];
    text.split(_CLOSE_CURLY).forEach((rule) {
      rules.add(parseRule(rule + _CLOSE_CURLY));
    });
    return rules;
  }
}
