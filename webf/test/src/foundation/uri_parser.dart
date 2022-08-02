/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:test/test.dart';
import 'package:webf/foundation.dart';

void main() {
  group('UriParser', () {
    var uriParser = UriParser();

    var resolveTests = [
      // base, relative, result
      ['https://foo.com', '//bar.org', 'https://bar.org'],
      ['https://foo.com', '/bar', 'https://foo.com/bar'],
      ['https://foo.com', 'file:///Users/bar', 'file:///Users/bar'],
      ['https://foo.com/?a=1', 'bar?b=2', 'https://foo.com/bar?b=2'],
      ['https://foo.com/?a=1', '//bar.org', 'https://bar.org'],
      ['assets:foo', './bar', 'assets:bar'],
      ['assets:foo', '/bar', 'assets:/bar'],
      ['assets:foo', './bar', 'assets:bar'],
      ['assets:foo', '../bar', 'assets:bar'],
      ['http://foo.com/bar', '../bar', 'http://foo.com/bar'],
      ['http://foo.com/bar', 'http://bar.com/', 'http://bar.com/'],
      ['file:///Users/foo', '/bar', 'file:///bar'],
      ['file:///Users/foo', 'bar', 'file:///Users/bar'],
      ['file:///Users/foo', '//foo.com/bar?a=1', 'file://foo.com/bar?a=1'],
    ];

    for (var spec in resolveTests) {
      String index = resolveTests.indexOf(spec).toString().padLeft(3, '0');

      test('resolve $index', () {
        Uri base = Uri.parse(spec[0]);
        Uri relative = Uri.parse(spec[1]);
        expect(uriParser.resolve(base, relative).toString(), spec[2]);
      });
    }
  });
}
