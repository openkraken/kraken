/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:webf/foundation.dart';

import '../../local_http_server.dart';

void main() {
  var server = LocalHttpServer.getInstance();

  group('Bundle', () {
    test('NetworkBundle basic', () async {
      Uri uri = server.getUri('js_over_128k');
      var bundle = NetworkBundle(uri.toString());
      // Using contextId to active cache.
      await bundle.resolve(1);
      Uint8List data = await bundle.data!;
      var code = utf8.decode(data);

      expect(bundle.isResolved, true);
      expect(code.length > 128 * 1024, true);
    });

    test('FileBundle basic', () async {
      var filename = '${Directory.current.path}/example/assets/bundle.js';
      var bundle = FileBundle('file://$filename');
      await bundle.resolve(1);

      expect(bundle.isResolved, true);
    });

    test('DataBundle string', () async {
      var content = 'hello world';
      var bundle = DataBundle.fromString(content, 'about:blank');
      await bundle.resolve(1);
      expect(bundle.isResolved, true);
      expect(utf8.decode(bundle.data!), content);
    });

    test('DataBundle with non-latin string', () async {
      var content = '你好,世界😈';
      var bundle = DataBundle.fromString(content, 'about:blank');
      await bundle.resolve(1);
      expect(bundle.isResolved, true);
      expect(utf8.decode(bundle.data!), content);
    });

    test('DataBundle data', () async {
      Uint8List bytecode = Uint8List.fromList(List.generate(10, (index) => index, growable: false));
      var bundle = DataBundle(bytecode, 'about:blank');
      await bundle.resolve(1);
      expect(bundle.isResolved, true);
      expect(bundle.data, bytecode);
    });

    test('WebFBundle', () async {
      Uint8List bytecode = Uint8List.fromList(List.generate(10, (index) => index, growable: false));
      var bundle = WebFBundle.fromBytecode(bytecode);
      await bundle.resolve(1);
      expect(bundle.contentType.mimeType, 'application/vnd.webf.bc1');
    });
  });
}
