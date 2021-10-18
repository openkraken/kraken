import 'package:kraken/css.dart';

// https://drafts.css-houdini.org/css-properties-values-api/#dependency-cycles
class CSSValue {
  String propertyName;
  RenderStyle renderStyle;
  CSSValue(this.propertyName, this.renderStyle);
}