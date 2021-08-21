import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// [LocalHttpServer] used for serving local HTTP servers.
/// Usage: putting `RAW HTTP Response` in txt to `res/$METHOD_$PATH`
/// Example:  `res/GET_foo` content will response to request that `GET /foo`
class LocalHttpServer {
  static LocalHttpServer? _instance;

  LocalHttpServer._() {
    _startServer();
  }

  static LocalHttpServer getInstance() {
    _instance ??= LocalHttpServer._();
    return _instance!;
  }

  static int _randomPort() {
    return Random().nextInt(55535) + 10000;
  }

  static String basePath = 'assets';

  final int port = _randomPort();
  ServerSocket? _server;

  Uri getUri([String? path]) {
    return Uri.http('${InternetAddress.loopbackIPv4.host}:$port', path ?? '');
  }

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
          File p = File('$basePath/${method}_${path.substring(1)}');
          if (!p.existsSync()) {
            throw FlutterError('Reading local http data, but file not exists: \n${p.absolute.path}');
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
