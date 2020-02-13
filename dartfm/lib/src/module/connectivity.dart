import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:kraken/bridge.dart';

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

void checkConnectivity(callbackId) {
  Connectivity().checkConnectivity().then((ConnectivityResult connectivityResult) {
    var isConnected = jsonEncode(ConnectivityResult.none != connectivityResult);
    bool hasCallback = callbackId > 0;
    String type = _parseConnectivityResult(connectivityResult);
    if (hasCallback) {
      invokeModuleCallback(callbackId, '{"isConnected": $isConnected, "type": "$type"}');
    }
  });
}
