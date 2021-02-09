import 'dart:convert';
import 'package:kraken/bridge.dart' as bridge;
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/src/module/navigator.dart';

abstract class BaseModule {
  String get name;
  final ModuleManager moduleManager;
  BaseModule(this.moduleManager);
  String invoke(String method, dynamic params, InvokeModuleCallback callback);
  void dispose();
}

typedef InvokeModuleCallback = void Function({String errmsg, dynamic data});
typedef NewModuleCreator = BaseModule Function(ModuleManager);

class ModuleManager {
  final int contextId;
  final KrakenController controller;

  static Map<String, BaseModule> _moduleMap = Map();
  static bool inited = false;

  ModuleManager(this.controller, this.contextId) {
    if (!inited) {
      defineModule(AsyncStorageModule(this));
      defineModule(ClipBoardModule(this));
      defineModule(ConnectionModule(this));
      defineModule(DeviceInfoModule(this));
      defineModule(FetchModule(this));
      defineModule(GeolocationModule(this));
      defineModule(MethodChannelModule(this));
      defineModule(MQTTModule(this));
      defineModule(NavigationModule(this));
      defineModule(NavigatorModule(this));
      defineModule(WebSocketModule(this));
    }
  }

  static void defineModule(BaseModule module) {
    if (_moduleMap.containsKey(module.name)) {
      throw Exception('ModuleManager: redefined module of type: ${module.name}');
    }

    _moduleMap[module.name] = module;
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
