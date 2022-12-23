/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
import 'dart:convert';

import 'package:kraken/bridge.dart' as bridge;
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';

abstract class BaseModule {
  String get name;
  final ModuleManager? moduleManager;
  BaseModule(this.moduleManager);
  String invoke(String method, params, InvokeModuleCallback callback);
  void dispose();
}

typedef InvokeModuleCallback = void Function({String ?error, Object? data});
typedef NewModuleCreator = BaseModule Function(ModuleManager);
typedef ModuleCreator = BaseModule Function(ModuleManager? moduleManager);

class ModuleManager {
  final int contextId;
  final KrakenController controller;

  static final Map<String, ModuleCreator> _creatorMap = {};
  static bool inited = false;
  final Map<String, BaseModule> _moduleMap = {};

  ModuleManager(this.controller, this.contextId) {
    if (!inited) {
      defineModule((ModuleManager? moduleManager) => AsyncStorageModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => ClipBoardModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => ConnectionModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => FetchModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => MethodChannelModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => NavigationModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => NavigatorModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => HistoryModule(moduleManager));
      defineModule((ModuleManager? moduleManager) => LocationModule(moduleManager));
      inited = true;
    }

    // Init all module instances.
    _creatorMap.forEach((String name, ModuleCreator creator) {
      _moduleMap[name] = creator(this);
    });
  }

  T? getModule<T extends BaseModule>(String moduleName) {
    return _moduleMap[moduleName] as T?;
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

  String invokeModule(String moduleName, String method, params, InvokeModuleCallback callback) {
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
