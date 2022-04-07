/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';

typedef ConnectedCallback = void Function();

const _white = Color(0xFFFFFFFF);

void launch({
  KrakenBundle? bundle,
  bool? debugEnableInspector,
  Color background = _white,
  DevToolsService? devToolsService,
  HttpClientInterceptor? httpClientInterceptor,
  bool? showPerformanceOverlay = false
}) async {
  // Bootstrap binding.
  ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();

  VoidCallback? _ordinaryOnMetricsChanged = window.onMetricsChanged;

  Future<void> _initKrakenApp() async {
    KrakenNativeChannel channel = KrakenNativeChannel();

    if (bundle == null) {
      String? backendEntrypointUrl = getBundleURLFromEnv() ?? getBundlePathFromEnv();
      backendEntrypointUrl ??= await channel.getUrl();
      if (backendEntrypointUrl != null) {
        bundle = KrakenBundle.fromUrl(backendEntrypointUrl);
      }
    }

    KrakenController controller = KrakenController(null, window.physicalSize.width / window.devicePixelRatio, window.physicalSize.height / window.devicePixelRatio,
      background: background,
      showPerformanceOverlay: showPerformanceOverlay ?? Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
      methodChannel: channel,
      entrypoint: bundle,
      devToolsService: devToolsService,
      httpClientInterceptor: httpClientInterceptor,
      autoExecuteEntrypoint: false,
    );

    controller.view.attachTo(RendererBinding.instance!.renderView);

    await controller.executeEntrypoint();
  }

  // window.physicalSize are Size.zero when app first loaded. This only happened on Android and iOS physical devices with release build.
  // We should wait for onMetricsChanged when window.physicalSize get updated from Flutter Engine.
  if (window.physicalSize == Size.zero) {
    window.onMetricsChanged = () async {
      if (window.physicalSize == Size.zero) {
        return;
      }

      await _initKrakenApp();

      // Should proxy to ordinary window.onMetricsChanged callbacks.
      if (_ordinaryOnMetricsChanged != null) {
        _ordinaryOnMetricsChanged();
        // Recover ordinary callback to window.onMetricsChanged
        window.onMetricsChanged = _ordinaryOnMetricsChanged;
      }
    };
  } else {
    await _initKrakenApp();
  }
}
