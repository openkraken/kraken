/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';

abstract class StyleSheet { }

const String _CSSStyleSheetType = 'text/css';

// https://drafts.csswg.org/cssom-1/#cssstylesheet
class CSSStyleSheet implements StyleSheet {
  String type = _CSSStyleSheetType;
  /// A Boolean indicating whether the stylesheet is disabled. False by default.
  bool disabled = false;
  /// A string containing the baseURL used to resolve relative URLs in the stylesheet.
  String? herf;

  CSSRuleList cssRules = CSSRuleList();

  Uri baseURL;

  CSSStyleSheet({ required this.baseURL, this.disabled = false });
  
  insertRule(String text, int index) {
    CSSRule rule = CSSParser.parseRule(text);
    cssRules.insert(rule, index);
  }

  /// Removes a rule from the stylesheet object.
  deleteRule(int index) {
    cssRules.removeAt(index);
  }

  /// Synchronously replaces the content of the stylesheet with the content passed into it.
  replaceSync(String text) {
    cssRules.clear();
    cssRules.addAll(CSSParser.parseRules(text));
  }

  replace(String text) {
    // TODO: put in next frame and return a future
    replaceSync(text);
  }
}

