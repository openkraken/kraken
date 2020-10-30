/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'bundle.dart';

// Error handler when load bundle failed.
typedef LoadErrorHandler = void Function(FlutterError error, StackTrace stack);

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
  KrakenController rootController;

  // The methods of the KrakenNavigateDelegation help you implement custom behaviors that are triggered
  // during a kraken view's process of loading, and completing a navigation request.
  KrakenNavigationDelegate navigationDelegate;

  KrakenViewController(double viewportWidth, double viewportHeight,
      {this.showPerformanceOverlay,
      this.enableDebug = false,
      int contextId,
      this.rootController,
      this.navigationDelegate})
      : _contextId = contextId {
    if (enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }

    if (_contextId == null) {
      _contextId = initBridge();
    }
    _elementManager = ElementManager(viewportWidth, viewportHeight,
        showPerformanceOverlayOverride: showPerformanceOverlay, controller: rootController);
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

  // Kraken have already disposed
  bool _disposed = false;

  bool get disposed => _disposed;

  // regenerate generate renderObject created by kraken but not affect jsBridge context.
  // test used only.
  testRefreshPaint() {
    // RenderObject root = _elementManager.getRootRenderObject();
    // RenderObject parent = root.parent;
    // RenderObject previousSibling;
    // if (parent is ContainerRenderObjectMixin) {
    //   previousSibling = (root.parentData as ContainerParentDataMixin).previousSibling;
    // }
    // detachView();
    // _elementManager = ElementManager(_elementManager.viewportWidth, _elementManager.viewportHeight,
    //     showPerformanceOverlayOverride: showPerformanceOverlay, controller: rootController);
    // attachView(parent, previousSibling);
  }

  void evaluateJavaScripts(String code, [String source = 'kraken://']) {
    assert(!_disposed, "Kraken have already disposed");
    evaluateScripts(_contextId, code, source, 0);
  }

  // attach kraken's renderObject to an renderObject.
  void attachView(RenderObject parent, [RenderObject previousSibling]) {
    _elementManager.attach(parent, previousSibling, showPerformanceOverlay: showPerformanceOverlay ?? false);
  }

  // dispose controller and recycle all resources.
  void dispose() {
    // break circle reference
    (_elementManager.getRootRenderObject() as RenderBoxModel).controller = null;

    detachView();
    disposeBridge(_contextId);

    // break circle reference
    _elementManager.getRootElement();
    _elementManager.controller = null;
    _elementManager = null;
    _disposed = true;
  }

  // export Uint8List bytes from rendered result.
  Future<Uint8List> toImage(double devicePixelRatio, [int eventTargetId = BODY_ID]) {
    assert(!_disposed, "Kraken have already disposed");
    Completer<Uint8List> completer = Completer();
    try {
      if (!_elementManager.existsTarget(eventTargetId)) {
        String msg = 'toImage: unknown node id: $eventTargetId';
        completer.completeError(Exception(msg));
        return completer.future;
      }

      var node = _elementManager.getEventTargetByTargetId<EventTarget>(eventTargetId);
      if (node is Element) {
        node.toBlob(devicePixelRatio: devicePixelRatio).then((Uint8List bytes) {
          completer.complete(bytes);
        }).catchError((e, stack) {
          String msg = 'toBlob: failed to export image data from element id: $eventTargetId. error: $e}.\n$stack';
          completer.completeError(Exception(msg));
        });
      } else {
        String msg = 'toBlob: node is not an element, id: $eventTargetId';
        completer.completeError(Exception(msg));
      }
    } catch (e, stack) {
      completer.completeError(e, stack);
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

  void handleNavigationAction(String sourceUrl, String targetUrl, KrakenNavigationType navigationType) async {
    KrakenNavigationAction action = KrakenNavigationAction(sourceUrl, targetUrl, navigationType);

    try {
      KrakenNavigationActionPolicy policy = await navigationDelegate.dispatchDecisionHandler(action);
      if (policy == KrakenNavigationActionPolicy.cancel) return;

      switch (action.navigationType) {
        case KrakenNavigationType.reload:
          rootController.reloadWithUrl(action.target);
          break;
        default:
        // for linkActivated and other type, we choose to do nothing.
      }
    } catch (e, stack) {
      if (navigationDelegate.errorHandler != null) {
        navigationDelegate.errorHandler(e, stack);
      }
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
  static Map<int, KrakenController> _controllerMap = Map();
  static Map<String, int> _nameIdMap = Map();

  static KrakenController getControllerOfJSContextId(int contextId) {
    if (!_controllerMap.containsKey(contextId)) {
      return null;
    }

    return _controllerMap[contextId];
  }

  static KrakenController getControllerOfName(String name) {
    if (!_nameIdMap.containsKey(name)) return null;
    int contextId = _nameIdMap[name];
    return getControllerOfJSContextId(contextId);
  }

  // Error handler when load bundle failed.
  LoadErrorHandler loadErrorHandler;

  KrakenMethodChannel _methodChannel;

  KrakenMethodChannel get methodChannel => _methodChannel;

  final String name;

  KrakenController(this.name, double viewportWidth, double viewportHeight,
      {bool showPerformanceOverlay = false,
      enableDebug = false,
      String bundleURL,
      String bundlePath,
      String bundleContent,
      KrakenNavigationDelegate navigationDelegate,
      KrakenMethodChannel methodChannel,
      this.loadErrorHandler})
      : _bundleURL = bundleURL,
        _bundlePath = bundlePath,
        _bundleContent = bundleContent {
    _methodChannel = methodChannel;
    _view = KrakenViewController(viewportWidth, viewportHeight,
        showPerformanceOverlay: showPerformanceOverlay,
        enableDebug: enableDebug,
        rootController: this,
        navigationDelegate: navigationDelegate ?? KrakenNavigationDelegate());
    _module = KrakenModuleController();
    assert(!_controllerMap.containsKey(_view.contextId),
        "found exist contextId of KrakenController, contextId: ${_view.contextId}");
    _controllerMap[_view.contextId] = this;
    assert(!_nameIdMap.containsKey(name), 'found exist name of KrakenController, name: $name');
    _nameIdMap[name] = _view.contextId;
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

  void setNavigationDelegate(KrakenNavigationDelegate delegate) {
    assert(_view != null);
    _view.navigationDelegate = delegate;
  }

  // reload current kraken view.
  void reload() async {
    assert(!_view._disposed, "Kraken have already disposed");
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
        contextId: _view.contextId,
        rootController: this,
        navigationDelegate: _view.navigationDelegate);
    _view.attachView(parent, previousSibling);
    await reloadJSContext(_view.contextId);
    await loadBundle();
    await run();
  }

  void reloadWithUrl(String url) async {
    assert(!_view._disposed, "Kraken have already disposed");
    _bundleURL = url;
    await reload();
  }

  void dispose() {
    _view.dispose();
    _module.dispose();
    _controllerMap[_view.contextId] = null;
    _controllerMap.remove(_view.contextId);
    _nameIdMap.remove(name);
  }

  String _bundleContent;

  String get bundleContent => _bundleContent;

  set bundleContent(String value) {
    if (value == null) return;
    _bundleContent = value;
  }

  String _bundlePath;

  String get bundlePath => _bundlePath;

  set bundlePath(String value) {
    if (value == null) return;
    _bundlePath = value;
  }

  String _bundleURL;

  String get bundleURL => _bundleURL;

  set bundleURL(String value) {
    if (value == null) return;
    _bundleURL = value;
  }

  // preload javascript source and cache it.
  void loadBundle({
    String bundleContentOverride,
    String bundlePathOverride,
    String bundleURLOverride,
  }) async {
    assert(!_view._disposed, "Kraken have already disposed");
    _bundleContent = _bundleContent ?? bundleContentOverride;
    _bundlePath = _bundlePath ?? bundlePathOverride;
    _bundleURL = _bundleURL ?? bundleURLOverride;
    String bundleURL =
        _bundleURL ?? _bundlePath ?? getBundleURLFromEnv() ?? getBundlePathFromEnv();

    if (bundleURL == null && methodChannel is KrakenNativeChannel) {
      bundleURL = await (methodChannel as KrakenNativeChannel).getUrl();
    }

    if (loadErrorHandler != null) {
      try {
        _bundle = await KrakenBundle.getBundle(bundleURL, contentOverride: _bundleContent);
      } catch(e, stack) { loadErrorHandler(FlutterError(e.toString()), stack);}
    } else {
      _bundle = await KrakenBundle.getBundle(bundleURL, contentOverride: _bundleContent);
    }
  }

  // execute preloaded javascript source
  void run() async {
    assert(!_view._disposed, "Kraken have already disposed");
    if (_bundle != null) {
      await _bundle.run(_view.contextId);
      // trigger window load event
      module.requestAnimationFrame((_) {
        String json = jsonEncode([WINDOW_ID, Event('load')]);
        emitUIEvent(_view.contextId, json);
      });
    }
  }
}
