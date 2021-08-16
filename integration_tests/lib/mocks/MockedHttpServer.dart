import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// [MockedHttpServer] used for mock HTTP servers.
/// Usage: putting `RAW HTTP Response` in txt to `mocks/http/$METHOD_$PATH.txt`
/// Example:  `mocks/http/GET_/foo.txt` content will response to request that `GET /foo`
class MockedHttpServer {
  static MockedHttpServer? _instance;

  MockedHttpServer._() {
    _startServer();
  }

  static MockedHttpServer getInstance() {
    if (_instance == null) {
      _instance = MockedHttpServer._();
    }
    return _instance!;
  }

  static int _randomPort() {
    return new Random().nextInt(55535) + 10000;
  }

  final int port = _randomPort();
  ServerSocket? _server;

  void _startServer() {
    ServerSocket.bind(InternetAddress.loopbackIPv4, port).then((ServerSocket server) {
      _server = server;
      server.listen((Socket socket) {
        socket.listen((List<int> chunk) {
          BytesBuilder methodBuilder = BytesBuilder();
          BytesBuilder pathBuilder = BytesBuilder();
          int state = 0; // state 0 -> method, state 1 -> path
          for (int byte in chunk) {
            // space
            if (byte == 32) {
              state ++;
              continue;
            }

            // \r
            if (byte == 13) {
              break;
            }

            if (state == 0) {
              methodBuilder.addByte(byte);
            } else if (state == 1) {
              pathBuilder.addByte(byte);
            }
          }
          String method = String.fromCharCodes(methodBuilder.takeBytes()).toUpperCase();
          String path = String.fromCharCodes(pathBuilder.takeBytes());

          // Example: GET_foo.txt represents `GET /foo`
          File p = File('mocks/http/${method}_${path.substring(1)}');
          if (!p.existsSync()) {
            throw FlutterError('Reading mock http data, but file not exists: \n${p.absolute.path}');
          }
          socket.add(p.readAsBytesSync());
        });
      });
    });
  }

  void close() {
    _server?.close();
    _server = null;
  }
}
