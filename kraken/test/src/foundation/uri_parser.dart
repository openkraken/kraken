import 'package:test/test.dart';
import 'package:kraken/foundation.dart';

void main() {
  group('UriParser', () {
    var uriParser = UriParser();

    var resolveTests = [
      // base, relative, result
      ['//foo.com', '//bar.org', 'https://bar.org'],
      ['//foo.com', '/bar', 'https://foo.com/bar'],
      ['//foo.com', 'file:///Users/bar', 'file:///Users/bar'],
      ['//foo.com/?a=1', 'bar?b=2', 'https://foo.com/bar?b=2'],
      ['//foo.com/?a=1', '//bar.org', 'https://bar.org'],
      ['file:///Users/foo', '/bar', 'file:///bar'],
      ['file:///Users/foo', 'bar', 'file:///Users/bar'],
      ['file:///Users/foo', '//foo.com/bar?a=1', 'file://foo.com/bar?a=1'],
    ];

    for (var spec in resolveTests) {
      String index = resolveTests.indexOf(spec)
          .toString()
          .padLeft(3, '0');

      test('resolve $index', () {
        Uri base = Uri.parse(spec[0]);
        Uri relative = Uri.parse(spec[1]);
        expect(uriParser.resolve(base, relative).toString(), spec[2]);
      });
    }
  });
}
