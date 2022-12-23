/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

import 'package:kraken/css.dart';

/// https://drafts.csswg.org/cssom/#the-cssstylerule-interface
class CSSStyleRule extends CSSRule {
  final String selectorText;
  final Map<String, String> style;

  CSSStyleRule(this.selectorText, this.style);
}
