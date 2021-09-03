import 'package:kraken/bridge.dart';
import 'package:kraken/src/module/module_manager.dart';

class NavigatorModule extends BaseModule {
  @override
  String get name => 'Navigator';

  NavigatorModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, dynamic params, callback) {
    if (method == 'getUserAgent') {
      return getKrakenInfo().userAgent;
    }
    return '';
  }
}
