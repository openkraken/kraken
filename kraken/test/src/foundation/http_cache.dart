import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:kraken/foundation.dart';
import '../../mock.dart';

void main() {
  var server = MockedHttpServer.getInstance();
  int contextId = 1;
  setupHttpOverrides(null, contextId: contextId);
  HttpClient httpClient = HttpClient();

  group('HttpCache', () {

    test('Simple http request with expires', () async {
      var request = await httpClient.openUrl('GET', Uri.parse(
          'http://127.0.0.1:${server.port}/001'));
      KrakenHttpOverrides.setContextHeader(request, contextId);
      var response = await request.close();
      expect(response.statusCode, 200);
      expect(response.headers.toString(), 'connection: keep-alive\n'
          'last-modified: Sun, 15 Mar 2020 11:32:20 GMT\n'
          'date: Mon, 16 Aug 2021 10:17:45 GMT\n'
          'accept-ranges: bytes\n'
          'content-length: 72\n'
          'content-md5: TuWzX7jF+yz4BB/EHT0Zng==\n'
          'etag: "4EE5B35FB8C5FB2CF8041FC41D3D199E"\n'
          'content-type: application/json\n'
          'expires: Mon, 16 Aug 2221 10:17:45 GMT\n'
          '');

      var data = await sinkStream(response);
      var content = jsonDecode(String.fromCharCodes(data));
      expect(content, {
        'method': 'GET',
        'data': {
          'userName': '12345'
        }
      });

      // second request
      var requestSecond = await httpClient.openUrl('GET', Uri.parse(
          'http://127.0.0.1:${server.port}/001'));
      KrakenHttpOverrides.setContextHeader(requestSecond, contextId);
      var responseSecond = await requestSecond.close();
      assert(responseSecond.headers.value('x-kraken-cache') != null);
    });
  });
}

Future<Uint8List> sinkStream(Stream<List<int>> stream) {
  var completer = Completer<Uint8List>();
  var buffer = BytesBuilder();
  stream
      .listen(buffer.add)
    ..onDone(() {
      completer.complete(buffer.takeBytes());
    })
    ..onError(completer.completeError);
  return completer.future;
}
