/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
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
        List<int> data = [];

        socket.listen((List<int> chunk) {
          data.addAll(chunk);

          if (data.length >= 4) {
            var lastFour = data.sublist(data.length - 4, data.length);

            // Ends with \r\n\r\n or
            // @TODO: content-length.
            if (lastFour[0] == 13 && lastFour[1] == 10 && lastFour[2] == 13 && lastFour[3] == 10) {
              var methodBuilder = BytesBuilder();
              var pathBuilder = BytesBuilder();

              int state = 0; // state 0 -> method, state 1 -> path
              for (int byte in data) {
                // space
                if (byte == 32) {
                  state++;
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
              File file = File('$basePath/${method}_${path.substring(1)}');
              if (!file.existsSync()) {
                throw FlutterError('Reading local http data, but file not exists: \n${file.absolute.path}');
              }

              file
                  .readAsBytes()
                  .then((Uint8List bytes) => utf8.decode(bytes))
                  .then((String input) => _format(input))
                  .then((String content) => utf8.encode(content))
                  .catchError((Object err, StackTrace? stack) => file.readAsBytes())
                  .then(socket.add)
                  .then((_) => socket.close());
            }
          }
        }, onError: (Object error, [StackTrace? stackTrace]) {
          print('$error $stackTrace');
        });
      });
    });
  }

  void close() {
    _server?.close();
    _server = null;
  }

  String _format(String input) {
    return input.replaceAll(RegExp(r'CURRENT_TIME', multiLine: true), HttpDate.format(DateTime.now()));
  }
}
