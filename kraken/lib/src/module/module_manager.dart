import 'dart:convert';
import 'package:kraken/bridge.dart' as bridge;
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/src/module/navigator.dart';

abstract class BaseModule {
  final ModuleManager moduleManager;
  BaseModule(this.moduleManager);
  String invoke(String method, dynamic params, InvokeModuleCallback callback);
  void dispose();
}

typedef InvokeModuleCallback = void Function({String errmsg, String data});
typedef NewModuleCreator = BaseModule Function(ModuleManager);

class ModuleManager {
  final int contextId;
  final KrakenController controller;

  static Map<String, BaseModule> _moduleMap = Map();
  static bool inited = false;

  ModuleManager(this.controller, this.contextId) {
    if (!inited) {
      defineModule('AsyncStorage', AsyncStorageModule(this));
      defineModule('Clipboard', ClipBoardModule(this));
      defineModule('Connection', ConnectionModule(this));
      defineModule('DeviceInfo', DeviceInfoModule(this));
      defineModule('fetch', FetchModule(this));
      defineModule('Geolocation', GeolocationModule(this));
      defineModule('MethodChannel', MethodChannelModule(this));
      defineModule('MQTT', MQTTModule(this));
      defineModule('Navigation', NavigationModule(this));
      defineModule('Navigator', NavigatorModule(this));
      defineModule('WebSocket', WebSocketModule(this));
    }
  }

  static void defineModule(String type, BaseModule module) {
    if (_moduleMap.containsKey(type)) {
      throw Exception('ModuleManager: redefined module of type: $type');
    }

    _moduleMap[type] = module;
  }

  void emitModuleEvent(String moduleName, {Event event, Object data}) {
    bridge.emitModuleEvent(contextId, moduleName, event, jsonEncode(data));
  }

  String invokeModule(String moduleName, String method, dynamic params, InvokeModuleCallback callback) {
    if (!_moduleMap.containsKey(moduleName)) {
      throw Exception('ModuleManager: Can not find module of name: $moduleName');
    }

    BaseModule module = _moduleMap[moduleName];
    return module.invoke(method, params, callback);
  }

  void dispose() {
    _moduleMap.forEach((key, module) {
      module.dispose();
    });
  }
}
