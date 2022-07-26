import 'package:kraken/module.dart';
import 'package:test/test.dart';

import '../../local_http_server.dart';

void main() {
  group('fetch', () {
    FetchModule fetchModule = FetchModule(null);
    var server = LocalHttpServer.getInstance();

    test('Custom Headers', () async {
      var request = await fetchModule.getRequest(
          server.getUri('plain_text'),
          'POST',
          <String, dynamic>{ 'foo': 'bar' },
          null
      );
      expect(request.uri.path, '/plain_text');
      expect(request.method, 'POST');
      expect(request.headers.value('foo'), 'bar');
      await request.close();
    });
  });
}
