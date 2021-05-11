/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/src/launcher/controller.dart';

import 'bundle.dart';

typedef ConnectedCallback = void Function();

void launch({
  String bundleURL,
  String bundlePath,
  String bundleContent,
  bool debugEnableInspector,
  Color background,
  DevToolsService devToolsService,
}) async {
  // Bootstrap binding.
  ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();

  KrakenController controller = KrakenController(null, window.physicalSize.width / window.devicePixelRatio, window.physicalSize.height / window.devicePixelRatio,
    background: background,
    showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
    methodChannel: KrakenNativeChannel(),
    debugEnableInspector: debugEnableInspector,
    devToolsService: devToolsService
  );

  controller.view.attachView(RendererBinding.instance.renderView);

  await controller.loadBundle(
      bundleURL: bundleURL,
      bundlePath: bundlePath,
      bundleContent: bundleContent);

  await controller.evalBundle();
}
