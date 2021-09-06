import 'package:kraken/css.dart';
import 'package:test/test.dart';

void main() {
  group('CSSParser', () {
    test('parseRules', () {
      List<CSSRule> rules = CSSParser.parseRules('.foo {color: red} \n .bar {}');
      expect((rules[0] as CSSStyleRule).selectorText, '.foo');
      expect((rules[1] as CSSStyleRule).selectorText, '.bar');
    });
  });
}
