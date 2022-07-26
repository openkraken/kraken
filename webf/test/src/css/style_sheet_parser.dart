import 'package:kraken/css.dart';
import 'package:test/test.dart';

void main() {
  group('CSSStyleSheetParser', () {
    test('1', () {
      List<CSSRule> rules = CSSStyleSheetParser.parse('.foo {color: red} \n .bar {}');
      expect(rules.length, 2);
      expect((rules[0] as CSSStyleRule).selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).style['color'], 'red');
      expect((rules[1] as CSSStyleRule).selectorText, '.bar');
    });

    test('2', () {
      List<CSSRule> rules = CSSStyleSheetParser.parse('{} \n .foo {color: red;} ;\n .bar {;;}');
      expect(rules.length, 2);
      expect((rules[0] as CSSStyleRule).selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).style['color'], 'red');
      expect((rules[1] as CSSStyleRule).selectorText, '.bar');
    });

    test('3', () {
      List<CSSRule> rules = CSSStyleSheetParser.parse('.foo {color: red;} .bar { .x {}; color: #aaa} .baz {}');
      expect(rules.length, 3);
      expect((rules[0] as CSSStyleRule).selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).style['color'], 'red');
      expect((rules[1] as CSSStyleRule).selectorText, '.bar');
      expect((rules[1] as CSSStyleRule).style['color'], '#aaa');
      expect((rules[2] as CSSStyleRule).selectorText, '.baz');
    });

    test('4', () {
      List<CSSRule> rules = CSSStyleSheetParser.parse('.foo {color: red} .bar {background: url(data:image/png;base64...)}');
      expect(rules.length, 2);
      expect((rules[0] as CSSStyleRule).selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).style['color'], 'red');
      expect((rules[1] as CSSStyleRule).selectorText, '.bar');
      expect((rules[1] as CSSStyleRule).style['background'], 'url(data:image/png;base64...)');
    });

    test('5', () {
      List<CSSRule> rules = CSSStyleSheetParser.parse('@charset "utf-8"; .foo {color: red}');
      expect(rules.length, 1);
      expect((rules[0] as CSSStyleRule).selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).style['color'], 'red');
    });

    test('6', () {
      List<CSSRule> rules = CSSStyleSheetParser.parse('''
        @media screen and (min-width: 900.5px) { }
        .foo {
          color: red
        }
      ''');
      expect(rules.length, 1);
      expect((rules[0] as CSSStyleRule).selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).style['color'], 'red');
    });
  });
}
