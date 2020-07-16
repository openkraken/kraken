/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
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

  KrakenViewController controller = KrakenViewController(
      showPerformanceOverlay: Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null);

  await controller.loadBundle(bundleURLOverride: bundleURLOverride,
    bundlePathOverride: bundlePathOverride,
    bundleContentOverride: bundleContentOverride);

  controller.attachView(RendererBinding.instance.renderView);

  await controller.run();
}
