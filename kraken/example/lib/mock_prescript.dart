import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/kraken.dart';

Future onJsBundleLoad(KrakenController controller) async{
  String script;
  try {
    script = _getAndroidPlatformInfo();
    if (script != null && script.isNotEmpty) {
      controller.view.evaluateJavaScripts(script);
    }
  } catch (e) {
    print(e);
  }
}

String _getAndroidPlatformInfo() {
  String script = '';
  try {
    //APP名称
    String appName = 'packageInfo.appName';
    //包名
    String packageName = 'packageInfo.packageName';
    //版本名
    String version = 'packageInfo.version';
    //版本号
    String buildNumber = 'packageInfo.buildNumber';

    String scene = '';
    String sceneInstanceId = '';

    MediaQueryData data =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    EdgeInsets insets = data.padding;
    MediaQueryData mediaQueryData = data;
    double devicePixelRatio = mediaQueryData.devicePixelRatio;

    script = 'window.device = {\n' +
        '  DeviceInfo: {\n' +
        "    name: 'androidDeviceInfo.device',\n" +
        '  },\n' +
        '  os: {\n' +
        "    name: 'Android',\n" +
        "    version: 'androidDeviceInfo.version.release'\n" +
        '  },\n' +
        '  app: {\n' +
        "    name: '$appName',\n" +
        "    packageName: '$packageName',\n" +
        "    buildNumber: '$buildNumber',\n" +
        "    scene: '$scene',\n" +
        "    sceneInstanceId: '$sceneInstanceId',\n" +
        "    version: '$version'\n" +
        '  },\n' +
        '  devicePixelRatio: $devicePixelRatio,\n' +
        '  display: {\n' +
        '    safeLeft: ${insets.left},\n' +
        '    safeTop: ${insets.top},\n' +
        '    safeRight: ${insets.right},\n' +
        '    safeBottom: ${insets.bottom}\n' +
        '  }\n' +
        '};';
  } catch (e) {
    print(e);
  }

  return script;
}
