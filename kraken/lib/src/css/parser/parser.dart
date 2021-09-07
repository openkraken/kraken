/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';

const String _CLOSE_CURLY = '}';

class CSSParser {
  static CSSRule parseRule(String text, {CSSStyleSheet? parentStyleSheet}) {
    // TODO: parse other css rule
    CSSRule rule = CSSStyleRuleParser.parse(text);
    rule.parentStyleSheet = parentStyleSheet;
    return rule;
  }

  static List<CSSRule> parseRules(String text, {CSSStyleSheet? parentStyleSheet}) {
    List<CSSRule> rules = [];
    text.split(_CLOSE_CURLY).forEach((ruleText) {
      CSSRule rule = parseRule(ruleText + _CLOSE_CURLY);
      rule.parentStyleSheet = parentStyleSheet;
      rules.add(rule);
    });
    return rules;
  }
}
