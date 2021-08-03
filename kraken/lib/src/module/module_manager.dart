import 'dart:convert';
import 'package:kraken/bridge.dart' as bridge;
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/dom.dart';

import 'navigator.dart';

abstract class BaseModule {
  String get name;
  final ModuleManager? moduleManager;
  BaseModule(this.moduleManager);
  String invoke(String method, dynamic params, InvokeModuleCallback callback);
  void dispose();
}

typedef InvokeModuleCallback = void Function({String ?error, dynamic data});
typedef NewModuleCreator = BaseModule Function(ModuleManager);
typedef ModuleCreator = BaseModule Function(ModuleManager? moduleNamager);

class ModuleManager {
  final int contextId;
  final KrakenController controller;

  static Map<String, ModuleCreator> _creatorMap = Map();
  static bool inited = false;
  Map<String, BaseModule> _moduleMap = Map();

  ModuleManager(this.controller, this.contextId) {
    if (!inited) {
      defineModule((ModuleManager? moduleManager) => AsyncStorageModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => ClipBoardModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => ConnectionModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => DeviceInfoModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => FetchModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => MethodChannelModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => NavigationModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => NavigatorModule(moduleManager));
      inited = true;
    }
  }

  static void defineModule(ModuleCreator moduleCreator) {
    BaseModule fakeModule = moduleCreator(null);
    if (_creatorMap.containsKey(fakeModule.name)) {
      throw Exception('ModuleManager: redefined module of type: ${fakeModule.name}');
    }

    _creatorMap[fakeModule.name] = moduleCreator;
  }

  void emitModuleEvent(String moduleName, {Event? event, Object? data}) {
    bridge.emitModuleEvent(contextId, moduleName, event, jsonEncode(data));
  }

  String invokeModule(String moduleName, String method, dynamic params, InvokeModuleCallback callback) {
    ModuleCreator? creator = _creatorMap[moduleName];
    if (creator == null) {
      throw Exception('ModuleManager: Can not find module of name: $moduleName');
    }

    if (!_moduleMap.containsKey(moduleName)) {
      _moduleMap[moduleName] = creator(this);
    }

    BaseModule module = _moduleMap[moduleName]!;
    return module.invoke(method, params, callback);
  }

  void dispose() {
    _moduleMap.forEach((key, module) {
      module.dispose();
    });
  }
}
