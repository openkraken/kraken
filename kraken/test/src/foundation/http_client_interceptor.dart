import 'dart:io';

import 'package:test/test.dart';
import 'package:kraken/foundation.dart';
import '../../mock.dart';

const int contextId = 2;
void main() {
  group('HttpClientInterceptor', () {
    setupHttpOverrides(TestHttpClientInterceptor(), contextId: contextId);
    HttpClient httpClient = HttpClient();

    test('beforeRequest', () async {
      var url = Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.host,
        port: MockedHttpServer.getInstance().port,
        path: '/002',
      );
      var request = await httpClient.getUrl(url);
      KrakenHttpOverrides.setContextHeader(request, contextId);
      request.headers.add('x-test-id', 'beforeRequest-001');

      await request.close();
      expect(request.headers.value('x-test-before-request'), 'modified');
    });

    test('afterResponse', () async {
      var url = Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.host,
        port: MockedHttpServer.getInstance().port,
        path: '/002',
      );
      var request = await httpClient.getUrl(url);
      KrakenHttpOverrides.setContextHeader(request, contextId);
      request.headers.add('x-test-id', 'afterResponse-001');

      var response = await request.close();
      expect(response.headers.value('x-test-after-response'), 'modified');
    });

    test('shouldInterceptRequest', () async {
      var url = Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.host,
        port: MockedHttpServer.getInstance().port,
        path: '/002',
      );
      var request = await httpClient.getUrl(url);
      KrakenHttpOverrides.setContextHeader(request, contextId);
      request.headers.add('x-test-id', 'shouldInterceptRequest-001');

      var response = await request.close();
      expect(String.fromCharCodes(await response.single), 'HelloWorld');
    });
  });
}

class TestHttpClientInterceptor implements HttpClientInterceptor {
  @override
  Future<HttpClientRequest?> beforeRequest(HttpClientRequest request) async {
    if (request.headers.value('x-test-id') == 'beforeRequest-001') {
      request.headers.add('x-test-before-request', 'modified');
    }
    return request;
  }

  @override
  Future<HttpClientResponse?> afterResponse(
      HttpClientRequest request, HttpClientResponse response) async {
    if (request.headers.value('x-test-id') == 'afterResponse-001') {
      return HttpClientStreamResponse(response, responseHeaders: {
        'x-test-after-response': 'modified',
      });
    }
    return response;
  }

  @override
  Future<HttpClientResponse?> shouldInterceptRequest(HttpClientRequest request) async {
    if (request.headers.value('x-test-id') == 'shouldInterceptRequest-001') {
      return HttpClientStreamResponse(Stream.value('HelloWorld'.codeUnits));
    }
    return null;
  }
}
