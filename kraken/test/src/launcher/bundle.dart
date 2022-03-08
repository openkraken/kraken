import 'dart:convert';
import 'dart:typed_data';

import 'package:kraken/launcher.dart';
import 'package:test/test.dart';

import '../../local_http_server.dart';

void main() {
  var server = LocalHttpServer.getInstance();

  group('Bundle', () {
    test('NetworkAssetsBundle basic', () async {
      Uri uri = server.getUri('js_over_128k');
      // Using contextId to active cache.
      var bundle = NetworkAssetBundle(uri, contextId: 1);
      ByteData data = await bundle.load(uri.toString());
      var code = utf8.decode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

      expect(code.length > 128 * 1024, true);
    });
  });
}
