/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:kraken/src/module/module_manager.dart';

DeviceInfoPlugin? _deviceInfoPlugin;

void _initDeviceInfoPlugin() {
  _deviceInfoPlugin ??= DeviceInfoPlugin();
}

class DeviceInfoModule extends BaseModule {
  @override
  String get name => 'DeviceInfo';

  static Future<Map> getDeviceInfo() async {
    _initDeviceInfoPlugin();
    Map<String, dynamic> deviceData;

    if (Platform.isAndroid) {
      deviceData = _readAndroidBuildData(await _deviceInfoPlugin!.androidInfo);
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await _deviceInfoPlugin!.iosInfo);
    } else if (Platform.isMacOS) {
      deviceData = {
        'brand': 'Apple',
        'platformName': 'Mac OS',
        'name': Platform.localeName,
        'isPhysicalDevice': true,
      };
    } else if (Platform.isLinux) {
      deviceData = {
        'platformName': 'Linux',
        'name': Platform.localeName,
        'isPhysicalDevice': true,
      };
    } else if (Platform.isWindows) {
      deviceData = {
        'platformName': 'Windows',
        'name': Platform.localeName,
        'isPhysicalDevice': true,
      };
    } else {
      deviceData = {};
    }

    return deviceData;
  }

  static int getHardwareConcurrency() {
    return Platform.numberOfProcessors;
  }

  DeviceInfoModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {
  }

  @override
  String invoke(String method, dynamic params, InvokeModuleCallback callback) {
    if (method == 'getDeviceInfo') {
      getDeviceInfo().then((Map json) {
        callback(data: json);
      });
    } else if (method == 'getHardwareConcurrency') {
      return getHardwareConcurrency().toString();
    }
    return '';
  }
}

Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    // Either a changelist number, or a label like 'M4-rc20'.
    'id': build.id, // For example: M4B30Z
    'brand': build.brand, // For example: google or Xiaomi
    'model': build.model, // For example: Nexus 9 or Mi 10
    'hardware': build.hardware, // For example: qcom
    'board': build.board, // For example: msm8998
    'platformName': 'Android',
    'platformVersion': build.version.release, // For example: 4.4.4
    'isPhysicalDevice': build.isPhysicalDevice
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  String id = data.utsname.machine;
  return <String, dynamic>{
    'id': id, // For example: iPhone12,1
    'brand': 'Apple',
    'model': data.model, // For example: iPhone or iPod, not the detail model name like 'iPhone 8'
    // The value of this property is an arbitrary alphanumeric string
    // that is associated with the device as an identifier.
    // For example, you can find the name of an iOS device in the General > About settings.
    'name': data.name,
    'platformName': data.systemName, // iPhone OS
    'platformVersion': data.systemVersion,
    'isPhysicalDevice': data.isPhysicalDevice
  };
}
