import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:io';
import '../element/event.dart';

enum _ConnectionState { closed }
typedef WebSocketEventCallback = void Function(String id, String event);

class _WebSocketState {
  _ConnectionState status;
  dynamic data;
  _WebSocketState(this.status);
}

class KrakenWebSocket {
  Map<String, IOWebSocketChannel> _clientMap = {};
  Map<String, Map<String, bool>> _listenMap = {};
  Map<String, _WebSocketState> _stateMap = {};
  int _clientId = 0;

  String init(String url, WebSocketEventCallback callback, {String protocols}) {
    var id = (_clientId++).toString();
    WebSocket.connect(url, protocols: [protocols]).then((webSocket) {
      IOWebSocketChannel client = IOWebSocketChannel(webSocket);
      _WebSocketState state = _stateMap[id];
      if (state != null && state.status == _ConnectionState.closed) {
        dynamic data = state.data;
        webSocket.close(data[0], data[1]);
        CloseEvent event = CloseEvent(data[0], data[1], true);
        callback(id, jsonEncode(event));
        _stateMap.remove(id);
        return;
      }
      _clientMap[id] = client;
      // Listen all event
      _listen(id, callback);
      // Emit open event
      String type = 'open';
      if (_hasListener(id, type)) {
        Event event = Event(type);
        callback(id, jsonEncode(event));
      }
    }).catchError((e, stack) {
      // print connection error internally and trigger error event.
      print(e);
      Event event = Event('error');
      callback(id, jsonEncode(event));
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
    var listeners = _listenMap[id];
    return listeners.containsKey(type);
  }

  void _listen(String id, WebSocketEventCallback callback) {
    IOWebSocketChannel client = _clientMap[id];

    client.stream.listen((message) {
      String type = 'message';
      if (!_hasListener(id, type)) return;
      MessageEvent event = MessageEvent(message);
      callback(id, jsonEncode(event));
    }, onError: (error) {
      String type = 'error';
      if (!_hasListener(id, type)) return;
      // print error internally and trigger error event;
      print(error);
      Event event = Event(type);
      callback(id, jsonEncode(event));
    }, onDone: () {
      String type = 'close';
      if (_hasListener(id, type)) {
        // CloseEvent https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent/CloseEvent
        CloseEvent event = CloseEvent(client.closeCode, client.closeReason, false);
        callback(id, jsonEncode(event));
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
