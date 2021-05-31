// @dart=2.9

/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';

/// https://drafts.csswg.org/cssom/#the-cssstylerule-interface
class CSSStyleRule {
  final String selectorText;
  final CSSStyleDeclaration _cssStyleDeclaration;

  CSSStyleDeclaration get style => _cssStyleDeclaration;
  CSSStyleRule(this.selectorText, this._cssStyleDeclaration);
}
