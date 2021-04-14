import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:kraken/inspector.dart';
import 'package:kraken/module.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/kraken.dart';
import 'package:ffi/ffi.dart';
import 'inspector.dart';

const String CONTENT_TYPE = 'Content-Type';
const String CONTENT_LENGTH = 'Content-Length';

typedef MessageCallback = void Function(Map<String, dynamic>);

Map<int, InspectServer> _inspectorServerMap = Map();

typedef Native_InspectorMessageCallback = Void Function(Pointer<Void> rpcSession, Pointer<Utf8> message);
typedef Dart_InspectorMessageCallback = void Function(Pointer<Void> rpcSession, Pointer<Utf8> message);
typedef Native_RegisterInspectorMessageCallback = Void Function(
    Int32 contextId,
    Pointer<Void> rpcSession,
    Pointer<NativeFunction<Native_InspectorMessageCallback>> inspectorMessageCallback);

typedef Native_AttachInspector = Void Function(Int32);
typedef Dart_AttachInspector = void Function(int);

void _registerInspectorMessageCallback(
    int contextId,
    Pointer<Void> rpcSession,
    Pointer<NativeFunction<Native_InspectorMessageCallback>> inspectorMessageCallback) {
  InspectServer server = _inspectorServerMap[contextId];
  if (server == null) {
    print('Internal error: can not get inspector server from contextId: $contextId');
    return;
  }
  Dart_InspectorMessageCallback nativeCallback = inspectorMessageCallback.asFunction();
  server.nativeInspectorMessageHandler = (String message) {
    nativeCallback(rpcSession, Utf8.toUtf8(message));
  };
}

typedef Native_InspectorMessage = Void Function(Int32 contextId, Pointer<Utf8>);

void _onInspectorMessage(int contextId, Pointer<Utf8> message) {
  InspectServer server = _inspectorServerMap[contextId];
  if (server == null) {
    print('Internal error: can not get inspector server from contextId: $contextId');
    return;
  }
  server.sendRawJSONToFrontend(Utf8.fromUtf8(message));
}

typedef Native_RegisterDartMethods = Void Function(Pointer<Uint64> methodBytes, Int32 length);
typedef Dart_RegisterDartMethods = void Function(Pointer<Uint64> methodBytes, int length);

typedef Native_DispatchInspectorTask = Void Function(Int32 contextId, Int32 taskId);
typedef Dart_DispatchInspectorTask = void Function(int contextId, int taskId);

void initInspectorServerNativeBinding(int contextId) {
  final Dart_RegisterDartMethods _registerInspectorServerDartMethods =
      nativeDynamicLibrary
          .lookup<NativeFunction<Native_RegisterDartMethods>>(
              'registerInspectorDartMethods')
          .asFunction();
  final Dart_AttachInspector _attachInspector = nativeDynamicLibrary
      .lookup<NativeFunction<Native_AttachInspector>>('attachInspector')
      .asFunction();
  final Pointer<NativeFunction<Native_InspectorMessage>>
      _nativeInspectorMessage = Pointer.fromFunction(_onInspectorMessage);
  final Pointer<NativeFunction<Native_RegisterInspectorMessageCallback>>
      _nativeRegisterInspectorMessageCallback = Pointer.fromFunction(_registerInspectorMessageCallback);

  final List<int> _dartNativeMethods = [
    _nativeInspectorMessage.address,
    _nativeRegisterInspectorMessageCallback.address
  ];

  Pointer<Uint64> bytes = allocate<Uint64>(count: _dartNativeMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
  nativeMethodList.setAll(0, _dartNativeMethods);

  _registerInspectorServerDartMethods(bytes, _dartNativeMethods.length);
  _attachInspector(contextId);
}

void serverIsolateEntryPoint(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);
  InspectServer server;
  int mainIsolateJSContextId;

  mainToIsolateStream.listen((data) {
    if (data is InspectorServerInit) {
      server = InspectServer(data.port, data.address, data.bundleURL);
      server.onStarted = () {
        isolateToMainStream.send(InspectorServerStart());
      };
      server.onFrontendMessage = (Map<String, dynamic> frontEndMessage) {
        isolateToMainStream.send(InspectorFrontEndMessage(frontEndMessage));
      };
      server.start();
      _inspectorServerMap[data.contextId] = server;
      mainIsolateJSContextId = data.contextId;
      initInspectorServerNativeBinding(data.contextId);
    } else if (server != null && server.connected) {
      if (data is InspectorEvent) {
        server.sendEventToFrontend(data);
      } else if (data is InspectorMethodResult) {
        server.sendToFrontend(data.id, data.result);
      } else if (data is InspectorNativeMessage) {
        assert(server.nativeInspectorMessageHandler != null);
        server.nativeInspectorMessageHandler(data.message);
      }
    } else if (data is InspectorPostTaskMessage) {
      server._dispatchInspectorTask(mainIsolateJSContextId, data.taskId);
    }
  });
}

class InspectServer {
  InspectServer(this.port, this.address, this.bundleURL);

  // final Inspector inspector;
  final String address;
  final String bundleURL;
  int port;

  VoidCallback onStarted;
  MessageCallback onFrontendMessage;
  HttpServer _httpServer;
  WebSocket _ws;

  NativeInspectorMessageHandler nativeInspectorMessageHandler;

  final Dart_DispatchInspectorTask _dispatchInspectorTask = nativeDynamicLibrary
      .lookup<NativeFunction<Native_DispatchInspectorTask>>('dispatchInspectorTask')
      .asFunction();

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
    _ws.add(message);
  }

  Map<String, dynamic> _parseMessage(message) {
    try {
      Map<String, dynamic> data = jsonDecode(message);
      return data;
    } catch (err) {
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
    request.response.headers
        .set(CONTENT_TYPE, 'application/json; charset=UTF-8');
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
    String entryURL = '${address}:${port}';
    _writeJSONObject(request, [
      {
        'description': '',
        'devtoolsFrontendUrl': '$INSPECTOR_URL?ws=$entryURL',
        'title': 'Kraken App',
        'type': 'page',
        'url': bundleURL,
        'webSocketDebuggerUrl': 'ws://$entryURL'
      }
    ]);
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
