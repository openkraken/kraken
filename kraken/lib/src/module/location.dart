/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/module.dart';

class LocationModule extends BaseModule {
  @override
  String get name => 'Location';

  LocationModule(ModuleManager? moduleManager) : super(moduleManager);

  String get href => moduleManager!.controller.url;

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
