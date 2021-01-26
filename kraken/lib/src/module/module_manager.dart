import 'package:kraken/bridge.dart' as bridge;
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/src/module/navigator.dart';

abstract class BaseModule {
  final ModuleManager moduleManager;
  BaseModule(this.moduleManager);
  String invoke(List<dynamic> params, InvokeModuleCallback callback);
  void dispose();
}

typedef InvokeModuleCallback = void Function(String);
typedef NewModuleCreator = BaseModule Function(ModuleManager);

class ModuleManager {
  final int contextId;
  final KrakenController controller;

  static Map<String, BaseModule> _moduleMap = Map();
  static bool inited = false;

  ModuleManager(this.controller, this.contextId) {
    if (!inited) {
      defineNewModule('AsyncStorage', AsyncStorageModule(this));
      defineNewModule('Clipboard', ClipBoardModule(this));
      defineNewModule('Connection', ConnectionModule(this));
      defineNewModule('DeviceInfo', DeviceInfoModule(this));
      defineNewModule('fetch', FetchModule(this));
      defineNewModule('Geolocation', GeolocationModule(this));
      defineNewModule('MethodChannel', MethodChannelModule(this));
      defineNewModule('MQTT', MQTTModule(this));
      defineNewModule('Navigation', NavigationModule(this));
      defineNewModule('Navigator', NavigatorModule(this));
      defineNewModule('WebSocket', WebSocketModule(this));
    }
  }

  static void defineNewModule(String type, BaseModule module) {
    if (_moduleMap.containsKey(type)) {
      throw Exception('ModuleManager: redefined module of type: $type');
    }

    _moduleMap[type] = module;
  }

  void emitModuleEvent(String json) {
    bridge.emitModuleEvent(contextId, json);
  }

  String invokeModule(String type, List<dynamic> params, InvokeModuleCallback callback) {
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
