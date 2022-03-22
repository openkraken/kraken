import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:kraken/launcher.dart';
import 'package:test/test.dart';

import '../../local_http_server.dart';

void main() {
  var server = LocalHttpServer.getInstance();

  group('Bundle', () {
    test('NetworkBundle basic', () async {
      Uri uri = server.getUri('js_over_128k');
      var bundle = NetworkBundle(uri.toString());
      // Using contextId to active cache.
      await bundle.resolve(1);
      ByteData data = await bundle.rawBundle!;
      var code = utf8.decode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

      expect(bundle.isResolved, true);
      expect(code.length > 128 * 1024, true);
    });

    test('FileBundle basic', () async {
      var filename = '${Directory.current.path}/example/assets/bundle.js';
      var bundle = FileBundle('file://$filename');
      await bundle.resolve(1);

      expect(bundle.isResolved, true);
      expect(bundle.content!.isNotEmpty, true);
    });

    test('RawBundle string', () async {
      var content = 'hello world';
      var bundle = RawBundle.fromString(content, 'about:blank');
      await bundle.resolve(1);
      expect(bundle.isResolved, true);
      expect(bundle.content, content);
    });

    test('RawBundle bytecode', () async {
      Uint8List bytecode = Uint8List.fromList(List.generate(10, (index) => index, growable: false));
      var bundle = RawBundle.fromBytecode(bytecode, 'about:blank');
      await bundle.resolve(1);
      expect(bundle.isResolved, true);
      expect(bundle.bytecode, bytecode);
    });
  });
}
