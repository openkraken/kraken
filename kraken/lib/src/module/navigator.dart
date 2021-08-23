import 'package:kraken/bridge.dart';
import 'package:kraken/src/module/module_manager.dart';
import 'package:vibration/vibration.dart';

class NavigatorModule extends BaseModule {
  @override
  String get name => 'Navigator';

  NavigatorModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, dynamic params, callback) {
    if (method == 'vibrate') {
      List methodArgs = params;
      if (methodArgs.length == 1) {
        int duration = methodArgs[0];
        Vibration.vibrate(duration: duration);
      } else {
        List<int> filteredArgs = [];
        for (var number in methodArgs) {
          if (number is double)
            filteredArgs.add(number.floor());
          else if (number is int) filteredArgs.add(number);
        }
        // Pattern must have even number of elements, default duration to 500ms.
        if (filteredArgs.length.isOdd) filteredArgs.add(500);
        Vibration.vibrate(pattern: filteredArgs);
      }
    } else if (method == 'cancelVibrate') {
      Vibration.cancel();
    } else if (method == 'getUserAgent') {
      return getKrakenInfo().userAgent;
    }
    return '';
  }
}
