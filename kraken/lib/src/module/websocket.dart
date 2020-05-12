import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:io';
import 'package:kraken/bridge.dart';

enum ConnectionState { closed }

class WebSocketState {
  ConnectionState status;
  dynamic data;
  WebSocketState(this.status);
}

Map<String, IOWebSocketChannel> _clientMap = {};
Map<String, Map<String, bool>> _listenMap = {};
Map<String, WebSocketState> _stateMap = {};
int _clientId = 0;

class KrakenWebSocket {
  static String init(String url, {String protocols}) {
    var id = (_clientId++).toString();
    WebSocket.connect(url, protocols: [protocols]).then((webSocket) {
      IOWebSocketChannel client = IOWebSocketChannel(webSocket);
      WebSocketState state = _stateMap[id];
      if (state != null && state.status == ConnectionState.closed) {
        dynamic data = state.data;
        webSocket.close(data[0], data[1]);
        String event = jsonEncode({'type': 'close', 'code': data[0], 'reason': data[1], 'wasClean': false});
        emitModuleEvent('["WebSocket", $id, $event]');
        _stateMap.remove(id);
        return;
      }
      _clientMap[id] = client;
      // Listen all event
      _listen(id);
      // Emit open event
      String type = 'open';
      if (_hasListener(id, type)) {
        String event = jsonEncode({
          'type': type,
        });
        emitModuleEvent('["WebSocket", $id, $event]');
      }
    });

    return id;
  }

  static void send(String id, String message) {
    IOWebSocketChannel client = _clientMap[id];

    if (client == null) return;

    client.sink.add(message);
  }

  static void close(String id, [int closeCode, String closeReason]) {
    IOWebSocketChannel client = _clientMap[id];
    // has not connect
    if (client == null) {
      if (!_stateMap.containsKey(id)) {
        WebSocketState state = WebSocketState(ConnectionState.closed);
        state.data = [closeCode, closeReason];
        _stateMap[id] = state;
      } else {
        WebSocketState state = _stateMap[id];
        state.status = ConnectionState.closed;
        state.data = [closeCode, closeReason];
      }
      return;
    }
    // connected
    client.sink.close(closeCode, closeReason);
  }

  static bool _hasListener(String id, String type) {
    var listeners = _listenMap[id];
    return listeners.containsKey(type);
  }

  static void _listen(String id) {
    IOWebSocketChannel client = _clientMap[id];

    client.stream.listen((message) {
      String type = 'message';
      if (!_hasListener(id, type)) return;
      String event = jsonEncode({
        'type': type,
        'data': message,
      });
      emitModuleEvent('["WebSocket", $id, $event]');
    }, onError: (error) {
      String type = 'error';
      if (!_hasListener(id, type)) return;
      String event = jsonEncode({'type': type});
      emitModuleEvent('["WebSocket", $id, $event]');
    }, onDone: () {
      String type = 'close';
      if (_hasListener(id, type)) {
        // CloseEvent https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent/CloseEvent
        String event =
            jsonEncode({'type': type, 'code': client.closeCode, 'reason': client.closeReason, 'wasClean': false});
        emitModuleEvent('["WebSocket", $id, $event]');
      }
      // Clear instance after close
      _listenMap.remove(id);
      _clientMap.remove(id);
      _stateMap.remove(id);
    });
  }

  static void addEvent(String id, String type) {
    if (!_listenMap.containsKey(id)) {
      // Init listener map
      _listenMap[id] = {};
    }

    // Mark event type listened
    var listeners = _listenMap[id];
    listeners[type] = true;
  }
}
