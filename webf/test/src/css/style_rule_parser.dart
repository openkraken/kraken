/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:test/test.dart';

void main() {
  group('CSSStyleRuleParser', () {
    test('1', () {
      CSSRule? rule = CSSStyleRuleParser.parse(' .foo { color: red; }');
      expect(rule is CSSStyleRule, true);

      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorText, '.foo');
      expect(styleRule.style['color'], 'red');
    });

    test('2', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('html{\n    color:black;\n}');
      expect(styleRule, isNotNull);
      expect(styleRule!.selectorText, 'html');
      expect(styleRule.style['color'], 'black');
    });

    test('3', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('/*\nSome Comments\nBaby \n*/\nhtml{\n    color:black;\n}');
      expect(styleRule!.selectorText, 'html');
      expect(styleRule.style['color'], 'black');
    });

    test('4', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('/*\nSome Comments\nBaby \n*/\nhtml{\n    color:black;\n}');
      expect(styleRule!.selectorText, 'html');
      expect(styleRule.style['color'], 'black');
    });

    test('5', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('.foo{--custom:some\n value;}');
      expect(styleRule!.selectorText, '.foo');
      expect(styleRule.style['--custom'], 'some value');
    });

    test('6', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('.foo{zoom;\ncolor: red \n}');
      expect(styleRule!.selectorText, '.foo');
      expect(styleRule.style['color'], 'red');
    });

    test('7', () {
      CSSStyleRule? styleRule =
          CSSStyleRuleParser.parse('.foo \t {background: url(data:image/png;base64, CNbyblAAAAHElEQVQI12P4) red}');
      expect(styleRule!.selectorText, '.foo');
      expect(styleRule.style['background'], 'url(data:image/png;base64, CNbyblAAAAHElEQVQI12P4) red');
    });

    test('8', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('.foo { color: rgb(255, 255, 0)}');
      expect(styleRule!.selectorText, '.foo');
      expect(styleRule.style['color'], 'rgb(255, 255, 0)');
    });

    test('9', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('.foo { background : ; color: rgb(255, 255, 0)}');
      expect(styleRule!.selectorText, '.foo');
      expect(styleRule.style['color'], 'rgb(255, 255, 0)');
    });

    test('10', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('th:nth-child(4) {color: rgb(255, 255, 0)}');
      expect(styleRule!.selectorText, 'th:nth-child(4)');
      expect(styleRule.style['color'], 'rgb(255, 255, 0)');
    });

    test('11', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('[hidden] { display: none }');
      expect(styleRule!.selectorText, '[hidden]');
      expect(styleRule.style['display'], 'none');
    });

    test('12', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('/**/ div > p { color: rgb(255, 255, 0);  } /**/');
      expect(styleRule!.selectorText, 'div > p');
      expect(styleRule.style['color'], 'rgb(255, 255, 0)');
    });

    test('13', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('.foo { background-image: url( "./image (1).jpg" )}');
      expect(styleRule!.selectorText, '.foo');
      expect(styleRule.style['backgroundImage'], 'url( "./image (1).jpg" )');
    });

    test('14', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse('.foo { .foo{ }; color: red}');
      expect(styleRule!.selectorText, '.foo');
      expect(styleRule.style['color'], 'red');
    });

    test('15', () {
      CSSStyleRule? styleRule = CSSStyleRuleParser.parse(' .foo {}');
      expect(styleRule!.selectorText, '.foo');
    });
  });
}
