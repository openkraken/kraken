import 'package:kraken/css.dart';
import 'package:test/test.dart';

void main() {
  group('CSSValues', () {

    group('CSSFunction', () {
      var cases = [
        'var(--x)',
        'url(https://some.com/path)',
        'conic-gradient(from 45deg, blue, red)',
        'device-cmyk(0 81% 81% 30% / .5, rgb(178 34 34))',
        'calc(var(--widthA) / 2)',
        'url(https://some.com/path), url(https://some.com/path2)'
        '''conic-gradient(
            hsl(360, 100%, 50%),
            hsl(315, 100%, 50%),
            hsl(270, 100%, 50%),
            hsl(225, 100%, 50%),
            hsl(180, 100%, 50%),
            hsl(135, 100%, 50%),
            hsl(90, 100%, 50%),
            hsl(45, 100%, 50%),
            hsl(0, 100%, 50%)
          )''',
      ];
      cases.forEach((String input) {
        test('simple case #${cases.indexOf(input)}', () {
          expect(CSSFunction.isFunction(input), true);
        });
      });

      test('specified function name #0', () {
        var input = 'var(--x)';
        expect(CSSFunction.isFunction(input, functionName: 'var'), true);
      });

      test('specified function name #1', () {
        var input = 'var(--x)';
        expect(CSSFunction.isFunction(input, functionName: 'var1'), false);
      });

      test('specified function name #2', () {
        var input = 'var(--x)';
        expect(CSSFunction.isFunction(input, functionName: 'url'), false);
      });

      test('specified function name #3', () {
        var input = 'conic-gradient(--x)';
        expect(CSSFunction.isFunction(input, functionName: 'conic-gradient'), true);
      });
    });
  });
}
