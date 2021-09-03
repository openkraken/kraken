/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';

class CSSRuleList {
  final List<CSSRule> _rules = [];
  CSSRule item(int index) {
    return _rules[index];
  }

  insert(CSSRule rule, int index) {
    _rules.insert(index, rule);
  }

  removeAt(int index) {
    _rules.removeAt(index);
  }

  clear(){
    _rules.clear();
  }

  addAll(List<CSSRule> rules) {
    _rules.addAll(rules);
  }
}
