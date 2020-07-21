/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ffi';
import 'dart:async';

import 'package:ffi/ffi.dart';
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
class KrakenViewController {
  KrakenViewController(double viewportWidth, double viewportHeight,
      {this.showPerformanceOverlay, this.enableDebug = false, int contextId})
      : _contextId = contextId {
    if (this.enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }

    if (_contextId == null) {
      _contextId = initBridge();
    }
    _elementManager = ElementManager(viewportWidth, viewportHeight,
        showPerformanceOverlayOverride: showPerformanceOverlay, controller: this);
  }

  // the manager which controller all renderObjects of Kraken
  ElementManager _elementManager;

  // index value which identify javascript runtime context.
  int _contextId;
  int get contextId {
    return _contextId;
  }

  // should render performanceOverlay layer into the screen for performance profile.
  bool showPerformanceOverlay;

  // print debug message when rendering.
  bool enableDebug;

  // regenerate generate renderObject created by kraken but not affect jsBridge context.
  // test used only.
  testRefreshPaint() {
    RenderObject root = _elementManager.getRootRenderObject();
    RenderObject parent = root.parent;
    RenderObject previousSibling;
    if (parent is ContainerRenderObjectMixin) {
      previousSibling = (root.parentData as ContainerParentDataMixin).previousSibling;
    }
    detachView();
    _elementManager = ElementManager(_elementManager.viewportWidth, _elementManager.viewportHeight,
        showPerformanceOverlayOverride: showPerformanceOverlay, controller: this);
    attachView(parent, previousSibling);
  }

  void evaluateJavaScripts(String code, [String source = 'kraken://']) {
    evaluateScripts(_contextId, code, source, 0);
  }

  // attach kraken's renderObject to an renderObject.
  void attachView(RenderObject parent, [RenderObject previousSibling]) {
    _elementManager.attach(parent, previousSibling, showPerformanceOverlay: showPerformanceOverlay ?? false);
  }

  // dispose controller and recycle all resources.
  void dispose() {
    detachView();
    disposeBridge(_contextId);

    // break circle reference
    _elementManager.controller._elementManager = null;
    _elementManager = null;
  }

  // export Uint8List bytes from rendered result.
  Future<Uint8List> toImage(double devicePixelRatio, [int eventTargetId = BODY_ID]) {
    Completer<Uint8List> completer = Completer();
    try {
      if (!_elementManager.existsTarget(eventTargetId)) {
        Pointer<Utf8> msg = Utf8.toUtf8('toImage: unknown node id: $eventTargetId');
        completer.completeError(new Exception(msg));
        return completer.future;
      }

      var node = _elementManager.getEventTargetByTargetId<EventTarget>(eventTargetId);
      if (node is Element) {
        node.toBlob(devicePixelRatio: devicePixelRatio).then((Uint8List bytes) {
          completer.complete(bytes);
        }).catchError((e, stack) {
          Pointer<Utf8> msg =
              Utf8.toUtf8('toBlob: failed to export image data from element id: $eventTargetId. error: $e}.\n$stack');
          completer.completeError(new Exception(msg));
        });
      } else {
        Pointer<Utf8> msg = Utf8.toUtf8('toBlob: node is not an element, id: $eventTargetId');
        completer.completeError(new Exception(msg));
      }
    } catch (e, stack) {
      Pointer<Utf8> msg = Utf8.toUtf8('toBlob: unexpected error: $e\n$stack');
      completer.completeError(new Exception(msg));
    }
    return completer.future;
  }

  String applyViewAction(String action, List payload) {
    var result = _elementManager.applyAction(action, payload);

    if (result == null) {
      return '';
    }

    switch (result.runtimeType) {
      case String:
        return result;
      case Map:
      case List:
        return jsonEncode(result);
      default:
        return result.toString();
    }
  }

  // detach renderObject from parent but keep everything in active.
  void detachView() {
    _elementManager.detach();
  }

  RenderObject getRootRenderObject() {
    return _elementManager.getRootRenderObject();
  }
}

// An controller designed to control kraken's functional modules.
class KrakenModuleController with TimerMixin, ScheduleFrameMixin {
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

  void dispose() {
    clearTimer();
    clearAnimationFrame();

    if (_websocket != null) {
      websocket.dispose();
    }

    if (_mqtt != null) {
      mqtt.dispose();
    }
  }
}

class KrakenController {
  static Map<int, KrakenController> _controllerMap = new Map();
  static KrakenController getControllerOfJSContextId(int contextId) {
    if (!_controllerMap.containsKey(contextId)) {
      return null;
    }

    return _controllerMap[contextId];
  }

  KrakenController(double viewportWidth, double viewportHeight,
      {bool showPerformanceOverlay = false, enableDebug = false}) {
    _view = KrakenViewController(viewportWidth, viewportHeight,
        showPerformanceOverlay: showPerformanceOverlay, enableDebug: enableDebug);
    _module = KrakenModuleController();
    _controllerMap[_view.contextId] = this;
  }

  KrakenViewController _view;
  KrakenViewController get view {
    return _view;
  }

  KrakenModuleController _module;
  KrakenModuleController get module {
    return _module;
  }

  // the bundle manager which used to download javascript source and run.
  KrakenBundle _bundle;

  // reload current kraken view.
  reload() async {
    RenderObject root = _view.getRootRenderObject();
    RenderObject parent = root.parent;
    RenderObject previousSibling;
    if (parent is ContainerRenderObjectMixin) {
      previousSibling = (root.parentData as ContainerParentDataMixin).previousSibling;
    }
    _module.dispose();
    _view.detachView();
    _view = KrakenViewController(view._elementManager.viewportWidth, view._elementManager.viewportHeight,
        showPerformanceOverlay: _view.showPerformanceOverlay,
        enableDebug: _view.enableDebug,
        contextId: _view.contextId);
    _view.attachView(parent, previousSibling);
    await reloadJSContext(_view.contextId);
    await run();
  }

  void dispose() {
    _view.dispose();
    _module.dispose();
    _controllerMap[_view.contextId] = null;
    _controllerMap.remove(_view.contextId);
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
      await _bundle.run(_view.contextId);
      // trigger window load event
      module.requestAnimationFrame((_) {
        String json = jsonEncode([WINDOW_ID, Event('load')]);
        emitUIEvent(_view.contextId, json);
      });
    } else {
      print('ERROR: No bundle found.');
    }
  }
}
