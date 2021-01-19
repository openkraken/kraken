import 'package:kraken/bridge.dart' as bridge;

abstract class BaseModule {
  final ModuleManager moduleManager;
  BaseModule(this.moduleManager);
  String invoke(List<dynamic> params, InvokeModuleCallback callback);
  void dispose();
}

typedef InvokeModuleCallback = void Function(String);

class ModuleManager {
  final int contextId;

  ModuleManager(this.contextId);
  static Map<String, BaseModule> _moduleMap = Map();

  void defineNewModule(String type, BaseModule module) {
    if (_moduleMap.containsKey(type)) {
      throw Exception('ModuleManager: redefined module of type: $type');
    }

    _moduleMap[type] = module;
  }

  void emitModuleEvent(String json) {
    bridge.emitModuleEvent(contextId, json);
  }

  String invokeModule(String type, List<String> params, InvokeModuleCallback callback) {
    if (!_moduleMap.containsKey(type)) {
      throw Exception('ModuleManager: Can not find module of type: $type');
    }

    BaseModule module = _moduleMap[type];
    return module.invoke(params, callback);
  }

  void dispose() {
    _moduleMap.forEach((key, module) {
      module.dispose();
    });
  }
}
