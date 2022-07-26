/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'package:connectivity/connectivity.dart';

import 'module_manager.dart';

Map _getResult(ConnectivityResult connectivityResult) {
  String type = _parseConnectivityResult(connectivityResult);
  return {'isConnected': ConnectivityResult.none != connectivityResult, 'type': type};
}

String _parseConnectivityResult(ConnectivityResult state) {
  switch (state) {
    case ConnectivityResult.wifi:
      return 'wifi';
    case ConnectivityResult.mobile:
      return 'cellular';
    case ConnectivityResult.none:
    default:
      return 'none';
  }
}

typedef OnConnectivityChangedCallback = void Function(Map json);

class ConnectionModule extends BaseModule {
  @override
  String get name => 'Connection';

  static Connectivity? _connectivity;

  static void _initConnectivity() {
    _connectivity ??= Connectivity();
  }

  static void getConnectivity(OnConnectivityChangedCallback callback) {
    _initConnectivity();
    _connectivity!.checkConnectivity().then((ConnectivityResult connectivityResult) {
      callback(_getResult(connectivityResult));
    });
  }

  static void onConnectivityChanged(OnConnectivityChangedCallback callback) {
    _initConnectivity();
    _connectivity!.onConnectivityChanged.listen((ConnectivityResult connectivityResul) {
      Map json = _getResult(connectivityResul);
      callback(json);
    });
  }

  ConnectionModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'getConnectivity': {
        getConnectivity((Map json) {
          callback(data: json);
        });
        break;
      }
      case 'onConnectivityChanged': {
        onConnectivityChanged((Map data) {
          moduleManager!.emitModuleEvent(name, data: data);
        });
        break;
      }
    }

    return '';
  }
}
