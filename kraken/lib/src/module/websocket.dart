import 'dart:io';

import 'package:kraken/dom.dart';
import 'package:web_socket_channel/io.dart';

import 'module_manager.dart';

enum _ConnectionState { closed }

typedef WebSocketEventCallback = void Function(String id, Event event);

class _WebSocketState {
  _ConnectionState status;
  dynamic data;

  _WebSocketState(this.status);
}

class WebSocketModule extends BaseModule {
  @override
  String get name => 'WebSocket';

  Map<String, IOWebSocketChannel> _clientMap = {};
  Map<String, Map<String, bool>> _listenMap = {};
  Map<String, _WebSocketState> _stateMap = {};
  int _clientId = 0;

  WebSocketModule(ModuleManager moduleManager) : super(moduleManager);

  @override
  String invoke(String method, dynamic params, callback) {
    if (method == 'init') {
      return init(params, (String id, Event event) {
        moduleManager.emitModuleEvent(name, event: event, data: id);
      });
    } else if (method == 'addEvent') {
      addEvent(params[0], params[1]);
    } else if (method == 'send') {
      send(params[0], params[1]);
    } else if (method == 'close') {
      close(params[0], params[1], params[2]);
    }
    return '';
  }

  @override
  void dispose() {
    _clientMap.forEach((id, socket) {
      socket.sink.close();
    });
    _clientMap.clear();
    _listenMap.clear();
    _stateMap.clear();
  }

  String init(String url, WebSocketEventCallback callback, {String protocols}) {
    var id = (_clientId++).toString();
    WebSocket.connect(url, protocols: [protocols]).then((webSocket) {
      IOWebSocketChannel client = IOWebSocketChannel(webSocket);
      _WebSocketState state = _stateMap[id];
      if (state != null && state.status == _ConnectionState.closed) {
        dynamic data = state.data;
        webSocket.close(data[0], data[1]);
        CloseEvent event = CloseEvent(data[0] ?? 0, data[1] ?? '', true);
        callback(id, event);
        _stateMap.remove(id);
        return;
      }
      _clientMap[id] = client;
      // Listen all event
      _listen(id, callback);
      if (_hasListener(id, EVENT_OPEN)) {
        Event event = Event(EVENT_OPEN);
        callback(id, event);
      }
    }).catchError((e, stack) {
      // print connection error internally and trigger error event.
      print(e);
      Event event = Event(EVENT_ERROR);
      callback(id, event);
    });

    return id;
  }

  void send(String id, String message) {
    IOWebSocketChannel client = _clientMap[id];

    if (client == null) return;

    client.sink.add(message);
  }

  void close(String id, [int closeCode, String closeReason]) {
    IOWebSocketChannel client = _clientMap[id];
    // has not connect
    if (client == null) {
      if (!_stateMap.containsKey(id)) {
        _WebSocketState state = _WebSocketState(_ConnectionState.closed);
        state.data = [closeCode, closeReason];
        _stateMap[id] = state;
      } else {
        _WebSocketState state = _stateMap[id];
        state.status = _ConnectionState.closed;
        state.data = [closeCode, closeReason];
      }
      return;
    }
    // connected
    client.sink.close(closeCode, closeReason);
  }

  bool _hasListener(String id, String type) {
    if (!_listenMap.containsKey(id)) return false;
    var listeners = _listenMap[id];
    return listeners.containsKey(type);
  }

  void _listen(String id, WebSocketEventCallback callback) {
    IOWebSocketChannel client = _clientMap[id];

    client.stream.listen((message) {
      if (!_hasListener(id, EVENT_MESSAGE)) return;
      MessageEvent event = MessageEvent(message);
      callback(id, event);
    }, onError: (error) {
      if (!_hasListener(id, EVENT_ERROR)) return;
      // print error internally and trigger error event;
      print(error);
      Event event = Event(EVENT_ERROR);
      callback(id, event);
    }, onDone: () {
      if (_hasListener(id, EVENT_CLOSE)) {
        // CloseEvent https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent/CloseEvent
        CloseEvent event = CloseEvent(client.closeCode, client.closeReason, false);
        callback(id, event);
      }
      // Clear instance after close
      _listenMap.remove(id);
      _clientMap.remove(id);
      _stateMap.remove(id);
    });
  }

  void addEvent(String id, String type) {
    if (!_listenMap.containsKey(id)) {
      // Init listener map
      _listenMap[id] = {};
    }

    // Mark event type listened
    var listeners = _listenMap[id];
    listeners[type] = true;
  }
}
