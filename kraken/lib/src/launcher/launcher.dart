/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/src/launcher/controller.dart';

import 'bundle.dart';

typedef ConnectedCallback = void Function();

void launch({
  String bundleURLOverride,
  String bundlePathOverride,
  String bundleContentOverride,
}) async {
  // Bootstrap binding.
  ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();

  KrakenController controller = KrakenController(null, window.physicalSize.width / window.devicePixelRatio, window.physicalSize.height / window.devicePixelRatio,
      showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
      methodChannel: KrakenNativeChannel());

  controller.view.attachView(RendererBinding.instance.renderView);

  await controller.loadBundle(
      bundleURLOverride: bundleURLOverride,
      bundlePathOverride: bundlePathOverride,
      bundleContentOverride: bundleContentOverride);

  await controller.run();
}
