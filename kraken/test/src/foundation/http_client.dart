import 'dart:io';

import 'package:test/test.dart';
import 'package:kraken/foundation.dart';

void main() {

  group('HttpHeaders', () {
    test('Simple modification and toString', () async {
      HttpHeaders headers = createHttpHeaders();
      expect(headers.toString(), '');

      headers.add('content-type', 'x-application/vnd.foo');
      expect(headers.toString(), 'content-type: x-application/vnd.foo');

      headers.add('content-type', 'another-value');
      expect(headers.toString(), 'content-type: x-application/vnd.foo\ncontent-type: another-value');

      headers.remove('content-type', 'x-application/vnd.foo');
      expect(headers.toString(), 'content-type: another-value');
    });

    test('Initial value', () async {
      HttpHeaders headers = createHttpHeaders(initialHeaders: {
        'content-type': ['x-application/vnd.foo', 'another-value']
      });
      expect(headers.toString(), 'content-type: x-application/vnd.foo\ncontent-type: another-value');
    });

    test('Remove all', () async {
      HttpHeaders headers = createHttpHeaders();
      headers.add('content-type', 'x-application/vnd.foo');
      headers.add('content-type', 'another-value');
      headers.removeAll('content-type');
      expect(headers.toString(), '');
    });


    test('Set', () async {
      HttpHeaders headers = createHttpHeaders();
      headers.add('content-type', 'x-application/vnd.foo');
      headers.add('content-type', 'another-value');

      headers.set('content-type', 'overwrite-value');
      expect(headers.toString(), 'content-type: overwrite-value');
    });

    test('operator[]', () async {
      HttpHeaders headers = createHttpHeaders();
      headers.add('content-type', 'x-application/vnd.foo');
      headers.add('content-type', 'another-value');

      expect(headers['content-type'], ['x-application/vnd.foo', 'another-value']);
    });
  });
}
