import 'dart:io' show Platform;
import 'package:kraken/bridge.dart';
import 'package:kraken/src/module/module_manager.dart';

String _customUserAgent;

class NavigatorModule extends BaseModule {
  @override
  String get name => 'Navigator';

  NavigatorModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, dynamic params, callback) {
    switch (method) {
      case 'getUserAgent':
        return getUserAgent();
      case 'getPlatform':
        return getPlaftorm();
      case 'getAppName':
        return getAppName();
      case 'getAppVersion':
        return getAppVersion();
      default:
        return '';
    }
  }

  static String getPlaftorm() {
    return Platform.operatingSystem;
  }

  static String getAppName() {
    KrakenInfo info = getKrakenInfo();
    return info.appName;
  }

  static String getAppVersion() {
    KrakenInfo info = getKrakenInfo();
    return info.appVersion;
  }

  static String getUserAgent() {
    if (_customUserAgent != null) {
      return _customUserAgent;
    }
    return getDefaultUserAgent();
  }

  static void setCustomUserAgent(String userAgent) {
    _customUserAgent = userAgent;
  }

  static String getDefaultUserAgent() {
    KrakenInfo info = getKrakenInfo();
    String appName = info.appName;
    String appVersion = info.appVersion;
    String appRevision = info.appRevision;
    String systemName = info.systemName;
    return '$appName/$appVersion ($systemName; $appName/$appRevision)';
  }
}
