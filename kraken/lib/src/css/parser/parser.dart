/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';
import './style_rule_parser.dart';


class CSSParser {
  static CSSRule parseRule(String text) {
    // TODO: parse other css rule
    return CSSStyleRuleParser.parse(text);
  }
  
  static List<CSSRule> parseRules(String text) {
    List<CSSRule> rules = [];
    text.split('}').forEach((rule) {
      rules.add(parseRule(rule));
    });
    return rules;
  }
}