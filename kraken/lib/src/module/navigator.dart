import 'package:kraken/src/module/module_manager.dart';
import 'package:vibration/vibration.dart';

class NavigatorModule extends BaseModule {
  NavigatorModule(ModuleManager moduleManager) : super(moduleManager);

  @override
  void dispose() {
  }

  @override
  String invoke(List<dynamic> params, callback) {
    String method = params[1];
    if (method == 'vibrate') {
      List methodArgs = params[2];
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
    }
    return '';
  }
}
