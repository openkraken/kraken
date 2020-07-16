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
import 'dart:ffi';
import 'bundle.dart';

int _poolSize = 4;
bool firstView = true;

void setJSContextPoolSize(int poolSize) {
  _poolSize = poolSize;
}

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
class KrakenViewController {
  static List<KrakenViewController> _viewControllerList = new List();
  static KrakenViewController getViewControllerOfJSContextIndex(int contextIndex) {
    if (contextIndex >= _viewControllerList.length) {
      return null;
    }
    if (_viewControllerList.elementAt(contextIndex) == null) {
      return null;
    }

    return _viewControllerList.elementAt(contextIndex);
  }

  ElementManager _elementManager;
  Pointer<JSBridge> _context;
  int _contextIndex;
  bool showPerformanceOverlay;
  KrakenBundle _bundle;

  String bundleURLOverride;
  String bundlePathOverride;
  String bundleContentOverride;

  bool enableDebug;

  KrakenViewController(
      {this.showPerformanceOverlay,
      this.enableDebug = false}) {
    if (this.enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }

    _contextIndex = initBridge(_poolSize, firstView);
    _context = getJSBridge(_contextIndex);

    _viewControllerList.add(this);

    firstView = false;

    _elementManager = ElementManager(
        jsContext: _context, jsContextIndex: _contextIndex, showPerformanceOverlayOverride: showPerformanceOverlay);
  }

  // reload current kraken view
  reloadCurrentView() async {
    RenderObject root = _elementManager.getRootRenderObject().parent;
    await _elementManager.detach();
    _elementManager.attach(root, showPerformanceOverlay: showPerformanceOverlay ?? false);
    await reloadJSContext(_context, _contextIndex);
  }

  // attach kraken's renderObject to an renderObject.
  void attachView(RenderObject parent) {
    _elementManager.attach(parent, showPerformanceOverlay: showPerformanceOverlay ?? false);
  }

  void detachView() {
    _elementManager.detach();
  }

  ElementManager getElementManager() {
    return _elementManager;
  }

  void loadBundle({
    String bundleContentOverride,
    String bundlePathOverride,
    String bundleURLOverride,
  }) async {
    // TODO native public API need to support KrakenViewController
    String bundleURL = bundleURLOverride ?? bundlePathOverride ?? getBundleURLFromEnv() ?? getBundlePathFromEnv();
    _bundle = await KrakenBundle.getBundle(bundleURL, contentOverride: bundleContentOverride);
  }

  void run() async {
    if (_bundle != null) {
      await _bundle.run(_context, _contextIndex);
      // trigger window load event
      requestAnimationFrame((_) {
        String json = jsonEncode([WINDOW_ID, Event('load')]);
        emitUIEvent(_context, _contextIndex, json);
      });
    } else {
      print('ERROR: No bundle found.');
    }
  }

  RenderObject getRootRenderObject() {
    return _elementManager.getRootRenderObject();
  }
}
