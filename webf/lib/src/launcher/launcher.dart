/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';

typedef ConnectedCallback = void Function();

const String BUNDLE_URL = 'WEBF_BUNDLE_URL';
const String BUNDLE_PATH = 'WEBF_BUNDLE_PATH';
const String ENABLE_DEBUG = 'WEBF_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'WEBF_ENABLE_PERFORMANCE_OVERLAY';
const _white = Color(0xFFFFFFFF);

String? getBundleURLFromEnv() {
  return Platform.environment[BUNDLE_URL];
}

String? getBundlePathFromEnv() {
  return Platform.environment[BUNDLE_PATH];
}

void launch(
    {WebFBundle? bundle,
    bool? debugEnableInspector,
    Color background = _white,
    DevToolsService? devToolsService,
    HttpClientInterceptor? httpClientInterceptor,
    bool? showPerformanceOverlay = false}) async {
  // Bootstrap binding.
  ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();

  VoidCallback? _ordinaryOnMetricsChanged = window.onMetricsChanged;

  Future<void> _initWebFApp() async {
    WebFNativeChannel channel = WebFNativeChannel();

    if (bundle == null) {
      String? backendEntrypointUrl = getBundleURLFromEnv() ?? getBundlePathFromEnv();
      backendEntrypointUrl ??= await channel.getUrl();
      if (backendEntrypointUrl != null) {
        bundle = WebFBundle.fromUrl(backendEntrypointUrl);
      }
    }

    WebFController controller = WebFController(
      null,
      window.physicalSize.width / window.devicePixelRatio,
      window.physicalSize.height / window.devicePixelRatio,
      background: background,
      showPerformanceOverlay: showPerformanceOverlay ?? Platform.environment[ENABLE_PERFORMANCE_OVERLAY] != null,
      methodChannel: channel,
      entrypoint: bundle,
      devToolsService: devToolsService,
      httpClientInterceptor: httpClientInterceptor,
      autoExecuteEntrypoint: false,
    );

    controller.view.attachTo(RendererBinding.instance.renderView);

    await controller.executeEntrypoint();
  }

  // window.physicalSize are Size.zero when app first loaded. This only happened on Android and iOS physical devices with release build.
  // We should wait for onMetricsChanged when window.physicalSize get updated from Flutter Engine.
  if (window.physicalSize == Size.zero) {
    window.onMetricsChanged = () async {
      if (window.physicalSize == Size.zero) {
        return;
      }

      await _initWebFApp();

      // Should proxy to ordinary window.onMetricsChanged callbacks.
      if (_ordinaryOnMetricsChanged != null) {
        _ordinaryOnMetricsChanged();
        // Recover ordinary callback to window.onMetricsChanged
        window.onMetricsChanged = _ordinaryOnMetricsChanged;
      }
    };
  } else {
    await _initWebFApp();
  }
}
