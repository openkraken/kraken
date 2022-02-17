import 'package:kraken/module.dart';

class LocationModule extends BaseModule {
  @override
  String get name => 'Location';

  LocationModule(ModuleManager? moduleManager) : super(moduleManager);

  String get href => moduleManager!.controller.currentBundleUrl;

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'getHref':
        return href;
      default:
        return '';
    }
  }

  @override
  void dispose() {}
}
