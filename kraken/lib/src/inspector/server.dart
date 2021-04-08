import 'dart:convert';
import 'dart:io';
import 'package:kraken/inspector.dart';
import 'package:kraken/module.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/kraken.dart';
import 'inspector.dart';

const String CONTENT_TYPE = 'Content-Type';
const String CONTENT_LENGTH = 'Content-Length';

typedef MessageCallback = void Function(Map<String, dynamic>);

class InspectServer {
  InspectServer(this.inspector, { this.port, this.address });

  final Inspector inspector;
  final String address;
  int port;

  VoidCallback onStarted;
  MessageCallback onFrontendMessage;
  HttpServer _httpServer;
  WebSocket _ws;

  /// InspectServer has connected frontend.
  bool get connected => _ws != null;

  int _bindServerRetryTime = 0;
  void _bindServer(int port) async {
    try {
      _httpServer = await HttpServer.bind(address, port);
      this.port = port;
    } on SocketException {
      if (_bindServerRetryTime < 10) {
        _bindServerRetryTime++;
        await _bindServer(port + 1);
      } else {
        rethrow;
      }
    }
  }

  Future<void> start() async {
    await _bindServer(port);

    if (onStarted != null) {
      onStarted();
    }

    await for (HttpRequest request in _httpServer) {
      HttpHeaders headers = request.headers;
      if (headers.value('upgrade') == 'websocket') {
        _ws = await WebSocketTransformer.upgrade(request);
        _ws.listen(onWebSocketRequest);
      } else {
        await onHTTPRequest(request);
      }
    }
  }

  void sendToFrontend(int id, JSONEncodable result) {
    assert(_ws != null, 'WebSocket should connect.');

    String data = jsonEncode({
      if (id != null) 'id': id,
      // Give an empty object for response.
      'result': result ?? {},
    });
    _ws.add(data);
  }

  void sendEventToFrontend(InspectorEvent event) {
    assert(_ws != null, 'WebSocket should connect.');
    _ws.add(jsonEncode(event));
  }

  void sendRawJSONToFrontend(String message) {
    assert(_ws != null, 'WebSocket should connect.');
    print('send raw message: $message');
    _ws.add(message);
  }

  Map<String, dynamic> _parseMessage(message) {
    try {
      Map<String, dynamic> data = jsonDecode(message);
      return data;
    } catch(err) {
      print('Error while decoding frontend message: $message');
      rethrow;
    }
  }

  void onWebSocketRequest(message) {
    if (message is String) {
      Map<String, dynamic> data = _parseMessage(message);
      if (onFrontendMessage != null) {
        onFrontendMessage(data);
      }
    }
  }

  void onHTTPRequest(HttpRequest request) async {
    switch (request.requestedUri.path) {
      case '/json/version':
        onRequestVersion(request);
        break;

      case '/json':
      case '/json/list':
        onRequestList(request);
        break;

      case '/json/new':
        onRequestNew(request);
        break;

      case '/json/close':
        onRequestClose(request);
        break;

      case '/json/protocol':
        onRequestProtocol(request);
        break;

      default:
        onRequestFallback(request);
        break;
    }
    await request.response.close();
  }

  void _writeJSONObject(HttpRequest request, Object obj) {
    String body = jsonEncode(obj);
    request.response.headers.set(CONTENT_TYPE, 'application/json; charset=UTF-8');
    request.response.headers.set(CONTENT_LENGTH, body.length);
    request.response.write(body);
  }

  void onRequestVersion(HttpRequest request) {
    request.response.headers.clear();
    KrakenInfo krakenInfo = getKrakenInfo();
    _writeJSONObject(request, {
      'Browser': 'Kraken/${krakenInfo.appVersion}',
      'Protocol-Version': '1.3',
      'User-Agent': krakenInfo.userAgent,
    });
  }

  void onRequestList(HttpRequest request) {
    request.response.headers.clear();
    String entryURL = '${inspector.address}:${inspector.port}';
    KrakenController controller = inspector.elementManager.controller;
    String bundleURL = controller.bundleURL ?? controller.bundlePath ?? '<EmbedBundle>';
    _writeJSONObject(request, [{
      'description': '',
      'devtoolsFrontendUrl': '$INSPECTOR_URL?ws=$entryURL',
      'title': 'Kraken App',
      'type': 'page',
      'url': bundleURL,
      'webSocketDebuggerUrl': 'ws://$entryURL'
    }]);
  }

  void onRequestClose(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestActivate(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestNew(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestProtocol(HttpRequest request) {
    onRequestFallback(request);
  }


  void onRequestFallback(HttpRequest request) {
    request.response.statusCode = 404;
    request.response.write('Unknown request.');
  }

  void dispose() async {
    onStarted = null;
    onFrontendMessage = null;

    await _ws?.close();
    await _httpServer?.close();
  }
}
