/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:kraken/module.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/devtools.dart';
import 'package:ffi/ffi.dart';
import '../bridge/platform.dart';

const String CONTENT_TYPE = 'Content-Type';
const String CONTENT_LENGTH = 'Content-Length';
const String FAVICON = 'https://gw.alicdn.com/tfs/TB1tTwGAAL0gK0jSZFxXXXWHVXa-144-144.png';

typedef MessageCallback = void Function(Map<String, dynamic>?);

Map<int, IsolateInspectorServer?> _inspectorServerMap = {};

typedef NativeInspectorMessageCallback = Void Function(Pointer<Void> rpcSession, Pointer<Utf8> message);
typedef DartInspectorMessageCallback = void Function(Pointer<Void> rpcSession, Pointer<Utf8> message);
typedef NativeRegisterInspectorMessageCallback = Void Function(
    Int32 contextId,
    Pointer<Void> rpcSession,
    Pointer<NativeFunction<NativeInspectorMessageCallback>> inspectorMessageCallback);
typedef NativeAttachInspector = Void Function(Int32);
typedef DartAttachInspector = void Function(int);
typedef NativeInspectorMessage = Void Function(Int32 contextId, Pointer<Utf8>);
typedef NativePostTaskToUIThread = Void Function(Int32 contextId, Pointer<Void> context, Pointer<Void> callback);
typedef NativeDispatchInspectorTask = Void Function(Int32 contextId, Pointer<Void> context, Pointer<Void> callback);
typedef DartDispatchInspectorTask = void Function(int? contextId, Pointer<Void> context, Pointer<Void> callback);

void _registerInspectorMessageCallback(
    int contextId,
    Pointer<Void> rpcSession,
    Pointer<NativeFunction<NativeInspectorMessageCallback>> inspectorMessageCallback) {
  IsolateInspectorServer? server = _inspectorServerMap[contextId];
  if (server == null) {
    print('Internal error: can not get inspector server from contextId: $contextId');
    return;
  }
  DartInspectorMessageCallback nativeCallback = inspectorMessageCallback.asFunction();
  server.nativeInspectorMessageHandler = (String message) {
    nativeCallback(rpcSession, (message).toNativeUtf8());
  };
}

void _onInspectorMessage(int contextId, Pointer<Utf8> message) {
  IsolateInspectorServer? server = _inspectorServerMap[contextId];
  if (server == null) {
    print('Internal error: can not get inspector server from contextId: $contextId');
    return;
  }
  String data = (message).toDartString();
  server.sendRawJSONToFrontend(data);
}

void _postTaskToUIThread(int contextId, Pointer<Void> context, Pointer<Void> callback) {
  IsolateInspectorServer? server = _inspectorServerMap[contextId];
  if (server == null) {
    print('Internal error: can not get inspector server from contextId: $contextId');
    return;
  }
  server.isolateToMainStream!.send(InspectorPostTaskMessage(context.address, callback.address));
}

void attachInspector(int contextId) {
  final DartAttachInspector _attachInspector = nativeDynamicLibrary
      .lookup<NativeFunction<NativeAttachInspector>>('attachInspector')
      .asFunction();
  _attachInspector(contextId);
}

void initInspectorServerNativeBinding(int contextId) {
  final DartRegisterDartMethods _registerInspectorServerDartMethods =
      nativeDynamicLibrary
          .lookup<NativeFunction<NativeRegisterDartMethods>>(
              'registerInspectorDartMethods')
          .asFunction();
  final Pointer<NativeFunction<NativeInspectorMessage>>
      _nativeInspectorMessage = Pointer.fromFunction(_onInspectorMessage);
  final Pointer<NativeFunction<NativeRegisterInspectorMessageCallback>>
      _nativeRegisterInspectorMessageCallback = Pointer.fromFunction(_registerInspectorMessageCallback);
  final Pointer<NativeFunction<NativePostTaskToUIThread>> _nativePostTaskToUIThread = Pointer.fromFunction(_postTaskToUIThread);

  final List<int> _dartNativeMethods = [
    _nativeInspectorMessage.address,
    _nativeRegisterInspectorMessageCallback.address,
    _nativePostTaskToUIThread.address
  ];

  Pointer<Uint64> bytes = malloc.allocate<Uint64>(_dartNativeMethods.length * sizeOf<Uint64>());
  Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
  nativeMethodList.setAll(0, _dartNativeMethods);

  _registerInspectorServerDartMethods(bytes, _dartNativeMethods.length);
}

void serverIsolateEntryPoint(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);
  IsolateInspectorServer? server;
  int? mainIsolateJSContextId;

  mainToIsolateStream.listen((data) {
    if (data is InspectorServerInit) {
      server = IsolateInspectorServer(data.port, data.address, data.bundleURL);
      server!._isolateToMainStream = isolateToMainStream;
      server!.onStarted = () {
        isolateToMainStream.send(InspectorServerStart());
      };
      server!.onFrontendMessage = (Map<String, dynamic>? frontEndMessage) {
        int? id = frontEndMessage!['id'];
        String _method = frontEndMessage['method'];
        Map<String, dynamic>? params = frontEndMessage['params'];

        List<String> moduleMethod = _method.split('.');
        String module = moduleMethod[0];
        String method = moduleMethod[1];

        // Runtime、Log、Debugger methods should handled on inspector isolate.
        if (module == 'Runtime' || module == 'Log' || module == 'Debugger') {
          server!.messageRouter(id, module, method, params);
        } else {
          isolateToMainStream.send(InspectorFrontEndMessage(id, module, method, params));
        }
      };
      server!.start();
      _inspectorServerMap[data.contextId] = server;
      mainIsolateJSContextId = data.contextId;
      // @TODO
      // initInspectorServerNativeBinding(data.contextId);
      // attachInspector(data.contextId);
    } else if (server != null && server!.connected) {
      if (data is InspectorEvent) {
        server!.sendEventToFrontend(data);
      } else if (data is InspectorMethodResult) {
        server!.sendToFrontend(data.id, data.result);
      } else if (data is InspectorPostTaskMessage) {
        final DartDispatchInspectorTask _dispatchInspectorTask = nativeDynamicLibrary
            .lookup<NativeFunction<NativeDispatchInspectorTask>>('dispatchInspectorTask')
            .asFunction();
        _dispatchInspectorTask(mainIsolateJSContextId, Pointer.fromAddress(data.context), Pointer.fromAddress(data.callback));
      } else if (data is InspectorReload) {
        // @TODO
        // attachInspector(data.contextId);
      }
    }
  });
}

class IsolateInspectorServer {
  IsolateInspectorServer(this.port, this.address, this.bundleURL) {
    // registerModule(InspectRuntimeModule(this));
    // registerModule(InspectDebuggerModule(this));
    registerModule(InspectorLogModule(this));
  }

  // final Inspector inspector;
  final String address;
  final String bundleURL;
  int port;

  VoidCallback? onStarted;
  MessageCallback? onFrontendMessage;
  late HttpServer _httpServer;
  WebSocket? _ws;

  SendPort? _isolateToMainStream;
  SendPort? get isolateToMainStream => _isolateToMainStream;

  NativeInspectorMessageHandler? nativeInspectorMessageHandler;

  final Map<String, IsolateInspectorModule> moduleRegistrar = {};

  void messageRouter(int? id, String module, String method, Map<String, dynamic>? params) {
    if (moduleRegistrar.containsKey(module)) {
      moduleRegistrar[module]!.invoke(id, method, params);
    }
  }

  void registerModule(IsolateInspectorModule module) {
    moduleRegistrar[module.name] = module;
  }

  /// InspectServer has connected frontend.
  bool get connected => _ws?.readyState == WebSocket.open;

  int _bindServerRetryTime = 0;

  Future<void> _bindServer(int port) async {
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
      onStarted!();
    }

    _httpServer.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer
          .upgrade(request, compression: CompressionOptions.compressionOff)
          .then((WebSocket webSocket) {
            _ws = webSocket;
            webSocket.listen(onWebSocketRequest, onDone: () {
              _ws = null;
            }, onError: (obj, stack) {
              _ws = null;
            });
          });
      } else {
        onHTTPRequest(request);
      }
    });
  }

  void sendToFrontend(int? id, Map? result) {
    String data = jsonEncode({
      if (id != null) 'id': id,
      // Give an empty object for response.
      'result': result ?? {},
    });
    _ws?.add(data);
  }

  void sendEventToFrontend(InspectorEvent event) {
    _ws?.add(jsonEncode(event));
  }

  void sendRawJSONToFrontend(String message) {
    _ws?.add(message);
  }

  Map<String, dynamic>? _parseMessage(message) {
    try {
      Map<String, dynamic>? data = jsonDecode(message);
      return data;
    } catch (err) {
      print('Error while decoding frontend message: $message');
      rethrow;
    }
  }

  void onWebSocketRequest(message) {
    if (message is String) {
      Map<String, dynamic>? data = _parseMessage(message);
      if (onFrontendMessage != null) {
        onFrontendMessage!(data);
      }
    }
  }

  Future<void> onHTTPRequest(HttpRequest request) async {
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
    // Must preserve header case, or chrome devtools inspector will drop data.
    request.response.headers
        .set(CONTENT_TYPE, 'application/json; charset=UTF-8', preserveHeaderCase: true);
    request.response.headers.set(CONTENT_LENGTH, body.length, preserveHeaderCase: true);
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
    String pageId = hashCode.toString();
    String entryURL = '$address:$port/devtools/page/$pageId';
    _writeJSONObject(request, [
      {
        'faviconUrl': FAVICON,
        'devtoolsFrontendUrl': '$INSPECTOR_URL?ws=$entryURL',
        'title': 'Kraken App',
        'id': pageId,
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
    await _httpServer.close();
  }
}
