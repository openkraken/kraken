import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'module_manager.dart';

String _toString(ConnectivityResult connectivityResult) {
  String isConnected = jsonEncode(ConnectivityResult.none != connectivityResult);
  String type = _parseConnectivityResult(connectivityResult);

  return '{"isConnected": $isConnected, "type": "$type"}';
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

typedef OnConnectivityChangedCallback = void Function(String json);

class ConnectionModule extends BaseModule {
  static Connectivity _connectivity;

  static void _initConnectivity() {
    if (_connectivity == null) {
      _connectivity = Connectivity();
    }
  }

  static void getConnectivity(callback) {
    _initConnectivity();
    _connectivity.checkConnectivity().then((ConnectivityResult connectivityResult) {
      callback(_toString(connectivityResult));
    });
  }

  static void onConnectivityChanged(OnConnectivityChangedCallback callback) {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult connectivityResul) {
      String json = _toString(connectivityResul);
      callback(json);
    });
  }

  ConnectionModule(ModuleManager moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(List<dynamic> params, InvokeModuleCallback callback) {
    String method = params[1];

    switch (method) {
      case 'getConnectivity': {
        getConnectivity((String json) {
          callback(json);
        });
        break;
      }
      case 'onConnectivityChanged': {
        onConnectivityChanged((String json) {
          moduleManager.emitModuleEvent('["onConnectivityChanged", $json]');
        });
        break;
      }
    }

    return '';
  }
}
