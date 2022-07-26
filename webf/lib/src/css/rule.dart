/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/css.dart';

abstract class CSSRule {
  String cssText = '';
  CSSStyleSheet? parentStyleSheet;
  CSSRule? parentRule;

  // https://drafts.csswg.org/cssom/#dom-cssrule-type
  // The following attribute and constants are historical.
  int? type;
  static const int STYLE_RULE = 1;
  static const int CHARSET_RULE = 2;
  static const int IMPORT_RULE = 3;
  static const int MEDIA_RULE = 4;
  static const int FONT_FACE_RULE = 5;
  static const int PAGE_RULE = 6;
  static const int MARGIN_RULE = 9;
  static const int NAMESPACE_RULE = 10;
}
