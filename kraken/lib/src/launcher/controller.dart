/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:kraken/bridge.dart';
import 'package:kraken/element.dart';
import 'package:kraken/module.dart';
import 'bundle.dart';

// See http://github.com/flutter/flutter/wiki/Desktop-shells
/// If the current platform is a desktop platform that isn't yet supported by
/// TargetPlatform, override the default platform to one that is.
/// Otherwise, do nothing.
/// No need to handle macOS, as it has now been added to TargetPlatform.
void setTargetPlatformForDesktop() {
  if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

// An kraken View Controller designed for multiple kraken view control.
class KrakenViewController with TimerMixin, ScheduleFrameMixin {
  static List<KrakenViewController> _viewControllerList = new List();
  static KrakenViewController getViewControllerOfJSBridgeIndex(int bridgeIndex) {
    if (bridgeIndex >= _viewControllerList.length) {
      return null;
    }
    if (_viewControllerList.elementAt(bridgeIndex) == null) {
      return null;
    }

    return _viewControllerList.elementAt(bridgeIndex);
  }

  KrakenViewController(
      {this.showPerformanceOverlay,
      this.enableDebug = false}) {
    if (this.enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }

    _contextIndex = initBridge();

    _viewControllerList.add(this);

    _elementManager = ElementManager(showPerformanceOverlayOverride: showPerformanceOverlay, controller: this);
  }

  // the manager which controller all renderObjects of Kraken
  ElementManager _elementManager;
  int get contextIndex {
    return _contextIndex;
  }

  // index value which identify javascript runtime context.
  int _contextIndex;

  // should render performanceOverlay layer into the screen for performance profile.
  bool showPerformanceOverlay;

  // the bundle manager which used to download javascript source and run.
  KrakenBundle _bundle;

  // the websocket instance
  KrakenWebSocket _websocket;
  KrakenWebSocket get websocket {
    if (_websocket == null) {
      _websocket = KrakenWebSocket();
    }

    return _websocket;
  }

  // the MQTT instance
  MQTT _mqtt;
  MQTT get mqtt {
    if (_mqtt == null) {
      _mqtt = MQTT();
    }
    return _mqtt;
  }

  // print debug message when rendering.
  bool enableDebug;

  // reload current kraken view.
  reloadCurrentView() async {
    RenderObject root = _elementManager.getRootRenderObject().parent;
    _elementManager.detach();
    _elementManager = ElementManager(showPerformanceOverlayOverride: showPerformanceOverlay, controller: this);
    _elementManager.attach(root, showPerformanceOverlay: showPerformanceOverlay ?? false);
    await reloadJSContext(_contextIndex);
    run();
  }

  // regenerate generate renderObject created by kraken but not affect jsBridge context.
  // test used only.
  testRefreshPaint() {
    RenderObject root = _elementManager.getRootRenderObject().parent;
    _elementManager.detach();
    _elementManager = ElementManager(showPerformanceOverlayOverride: showPerformanceOverlay, controller: this);
    _elementManager.attach(root, showPerformanceOverlay: showPerformanceOverlay ?? false);
  }

  // attach kraken's renderObject to an renderObject.
  void attachView(RenderObject parent) {
    _elementManager.attach(parent, showPerformanceOverlay: showPerformanceOverlay ?? false);
  }

  // dispose controller and recycle all resources.
  void dispose() {
    detachView();
    disposeBridge(_contextIndex);
    _viewControllerList[_contextIndex] = null;
    clearTimer();
    clearAnimationFrame();

    if (_websocket != null) {
      websocket.dispose();
    }

    if (_mqtt != null) {
      mqtt.dispose();
    }

    // break circle reference
    _elementManager.controller._elementManager = null;
    _elementManager = null;
  }

  // detach renderObject from parent but keep everything in active.
  void detachView() {
    _elementManager.detach();
  }

  ElementManager getElementManager() {
    return _elementManager;
  }

  // preload javascript source and cache it.
  void loadBundle({
    String bundleContentOverride,
    String bundlePathOverride,
    String bundleURLOverride,
  }) async {
    // TODO native public API need to support KrakenViewController
    String bundleURL = bundleURLOverride ?? bundlePathOverride ?? getBundleURLFromEnv() ?? getBundlePathFromEnv();
    _bundle = await KrakenBundle.getBundle(bundleURL, contentOverride: bundleContentOverride);
  }

  // execute preloaded javascript source
  void run() async {
    if (_bundle != null) {
      await _bundle.run(_contextIndex);
      // trigger window load event
      requestAnimationFrame((_) {
        String json = jsonEncode([WINDOW_ID, Event('load')]);
        emitUIEvent(_contextIndex, json);
      });
    } else {
      print('ERROR: No bundle found.');
    }
  }

  RenderObject getRootRenderObject() {
    return _elementManager.getRootRenderObject();
  }
}
