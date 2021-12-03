/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/widget.dart';

import 'bundle.dart';

// Error handler when load bundle failed.
typedef LoadHandler = void Function(KrakenController controller);
typedef LoadErrorHandler = void Function(FlutterError error, StackTrace stack);
typedef JSErrorHandler = void Function(String message);

typedef TraverseElementCallback = void Function(Element element);

// Traverse DOM element.
void traverseElement(Element element, TraverseElementCallback callback) {
  callback(element);
  for (Element el in element.children) {
    traverseElement(el, callback);
  }
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

abstract class DevToolsService {
  void init(KrakenController controller);
  void willReload();
  void didReload();
  void dispose();
}

// An kraken View Controller designed for multiple kraken view control.
class KrakenViewController {
  KrakenController rootController;

  // The methods of the KrakenNavigateDelegation help you implement custom behaviors that are triggered
  // during a kraken view's process of loading, and completing a navigation request.
  KrakenNavigationDelegate? navigationDelegate;

  GestureListener? gestureListener;

  double _viewportWidth;
  double get viewportWidth => _viewportWidth;
  set viewportWidth(double value) {
    if (value != _viewportWidth) {
      _viewportWidth = value;
      viewport.viewportSize = Size(_viewportWidth, _viewportHeight);
    }
  }

  double _viewportHeight;
  double get viewportHeight => _viewportHeight;
  set viewportHeight(double value) {
    if (value != _viewportHeight) {
      _viewportHeight = value;
      viewport.viewportSize = Size(_viewportWidth, _viewportHeight);
    }
  }

  Color? background;

  WidgetDelegate? widgetDelegate;

  KrakenViewController(
    this._viewportWidth,
    this._viewportHeight, {
    this.background,
    this.showPerformanceOverlay,
    this.enableDebug = false,
    int? contextId,
    required this.rootController,
    this.navigationDelegate,
    this.gestureListener,
    this.widgetDelegate,
  }) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_VIEW_CONTROLLER_PROPERTY_INIT);
    }

    if (enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_BRIDGE_INIT_START);
    }

    _contextId = contextId ?? initBridge();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_BRIDGE_INIT_END);
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_VIEWPORT_START);
    }

    viewport = RenderViewportBox(
      background: background,
      viewportSize: Size(viewportWidth, viewportHeight),
      gestureListener: gestureListener,
      controller: rootController
    );

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_VIEWPORT_END);
      PerformanceTiming.instance().mark(PERF_ELEMENT_MANAGER_INIT_START);
    }

    _elementManager = ElementManager(
      contextId: _contextId,
      viewport: viewport,
      showPerformanceOverlayOverride: showPerformanceOverlay,
      controller: rootController,
      gestureListener: gestureListener,
      widgetDelegate: widgetDelegate,
    );

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ELEMENT_MANAGER_INIT_END);
    }
  }

  // the manager which controller all renderObjects of Kraken
  late ElementManager _elementManager;
  ElementManager get elementManager => _elementManager;

  // index value which identify javascript runtime context.
  late int _contextId;
  int get contextId => _contextId;

  // should render performanceOverlay layer into the screen for performance profile.
  bool? showPerformanceOverlay;

  // print debug message when rendering.
  bool enableDebug;

  // Kraken have already disposed
  bool _disposed = false;

  bool get disposed => _disposed;

  late RenderViewportBox viewport;

  void evaluateJavaScripts(String code, [String source = 'vm://']) {
    assert(!_disposed, 'Kraken have already disposed');
    evaluateScripts(_contextId, code, source);
  }

  // attach kraken's renderObject to an renderObject.
  void attachView(RenderObject parent, [RenderObject? previousSibling]) {
    _elementManager.attach(parent, previousSibling, showPerformanceOverlay: showPerformanceOverlay ?? false);
  }

  Window? get window => getEventTargetById(WINDOW_ID) as Window?;

  Document? get document => getEventTargetById(DOCUMENT_ID) as Document?;

  // dispose controller and recycle all resources.
  void dispose() {
    // break circle reference
    (_elementManager.getRootRenderBox() as RenderObjectWithControllerMixin).controller = null;

    detachView();

    // should clear previous page cached ui commands
    clearUICommand(_contextId);

    disposeContext(_contextId);

    // DisposeEventTarget command will created when js context disposed, should flush them all.
    flushUICommand();

    _elementManager.dispose();
    _disposed = true;
  }

  // export Uint8List bytes from rendered result.
  Future<Uint8List> toImage(double devicePixelRatio, [int eventTargetId = HTML_ID]) {
    assert(!_disposed, 'Kraken have already disposed');
    Completer<Uint8List> completer = Completer();
    try {
      if (!_elementManager.existsTarget(eventTargetId)) {
        String msg = 'toImage: unknown node id: $eventTargetId';
        completer.completeError(Exception(msg));
        return completer.future;
      }

      var node = _elementManager.getEventTargetByTargetId<EventTarget>(eventTargetId);
      if (node is Element) {
        if (!node.isRendererAttached) {
          String msg = 'toImage: the element is not attached to document tree.';
          completer.completeError(Exception(msg));
          return completer.future;
        }

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

  Element createElement(int id, Pointer<NativeEventTarget> nativePtr, String tagName) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_ELEMENT_START, uniqueId: id);
    }
    Element result = _elementManager.createElement(id, nativePtr, tagName.toUpperCase(), null, null);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_ELEMENT_END, uniqueId: id);
    }
    return result;
  }

  void createTextNode(int id, Pointer<NativeEventTarget> nativePtr, String data) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_TEXT_NODE_START, uniqueId: id);
    }
    _elementManager.createTextNode(id, nativePtr, data);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_TEXT_NODE_END, uniqueId: id);
    }
  }

  void createComment(int id, Pointer<NativeEventTarget> nativePtr) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_COMMENT_START, uniqueId: id);
    }
    _elementManager.createComment(id, nativePtr);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_COMMENT_END, uniqueId: id);
    }
  }

  void addEvent(int targetId, String eventType) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ADD_EVENT_START, uniqueId: targetId);
    }
    _elementManager.addEvent(targetId, eventType);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ADD_EVENT_END, uniqueId: targetId);
    }
  }

  void removeEvent(int targetId, String eventType) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_REMOVE_EVENT_START, uniqueId: targetId);
    }
    _elementManager.removeEvent(targetId, eventType);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_REMOVE_EVENT_END, uniqueId: targetId);
    }
  }

  void insertAdjacentNode(int targetId, String position, int childId) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_INSERT_ADJACENT_NODE_START, uniqueId: targetId);
    }
    _elementManager.insertAdjacentNode(targetId, position, childId);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_INSERT_ADJACENT_NODE_END, uniqueId: targetId);
    }
  }

  void removeNode(int targetId) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_REMOVE_NODE_START, uniqueId: targetId);
    }
    _elementManager.removeNode(targetId);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_REMOVE_NODE_END, uniqueId: targetId);
    }
  }

  void cloneNode(int oldId, int newId) {
    _elementManager.cloneNode(oldId, newId);
  }

  void setInlineStyle(int targetId, String key, String value) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_STYLE_START, uniqueId: targetId);
    }
    _elementManager.setInlineStyle(targetId, key, value);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_STYLE_END, uniqueId: targetId);
    }
  }

  void flushPendingStyleProperties(int targetId) {
    _elementManager.flushPendingStyleProperties(targetId);
  }

  void setProperty(int targetId, String key, String value) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_PROPERTIES_START, uniqueId: targetId);
    }
    _elementManager.setProperty(targetId, key, value);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_PROPERTIES_END, uniqueId: targetId);
    }
  }

  void removeProperty(int targetId, String key) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_PROPERTIES_START, uniqueId: targetId);
    }
    _elementManager.removeProperty(targetId, key);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_PROPERTIES_END, uniqueId: targetId);
    }
  }

  void createDocumentFragment(int targetId, Pointer<NativeEventTarget> nativePtr) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_DOCUMENT_FRAGMENT_START, uniqueId: targetId);
    }
    _elementManager.createDocumentFragment(targetId, nativePtr);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_DOCUMENT_FRAGMENT_END, uniqueId: targetId);
    }
  }

  EventTarget? getEventTargetById(int id) {
    return _elementManager.getEventTargetByTargetId<EventTarget>(id);
  }

  Future<void> handleNavigationAction(String? sourceUrl, String targetUrl, KrakenNavigationType navigationType) async {
    KrakenNavigationAction action = KrakenNavigationAction(sourceUrl, targetUrl, navigationType);

    KrakenNavigationDelegate _delegate = navigationDelegate!;

    try {
      KrakenNavigationActionPolicy policy = await _delegate.dispatchDecisionHandler(action);
      if (policy == KrakenNavigationActionPolicy.cancel) return;

      switch (action.navigationType) {
        case KrakenNavigationType.navigate:
          await rootController.reload(url: action.target);
          break;
        case KrakenNavigationType.reload:
          await rootController.reload(url: action.source!);
          break;
        default:
        // Navigate and other type, do nothing.
      }
    } catch (e, stack) {
      if (_delegate.errorHandler != null) {
        _delegate.errorHandler!(e, stack);
      } else {
        print('Kraken navigation failed: $e\n$stack');
      }
    }
  }

  // detach renderObject from parent but keep everything in active.
  void detachView() {
    _elementManager.detach();
  }

  RenderObject getRootRenderObject() {
    return _elementManager.getRootRenderBox();
  }
}

// An controller designed to control kraken's functional modules.
class KrakenModuleController with TimerMixin, ScheduleFrameMixin {
  late ModuleManager _moduleManager;
  ModuleManager get moduleManager => _moduleManager;

  KrakenModuleController(KrakenController controller, int contextId) {
    _moduleManager = ModuleManager(controller, contextId);
  }

  void dispose() {
    clearTimer();
    clearAnimationFrame();
    _moduleManager.dispose();
  }
}

class KrakenController {
  static final SplayTreeMap<int, KrakenController?> _controllerMap = SplayTreeMap();
  static final Map<String, int> _nameIdMap = {};

  UriParser? uriParser;

  static KrakenController? getControllerOfJSContextId(int? contextId) {
    if (!_controllerMap.containsKey(contextId)) {
      return null;
    }

    return _controllerMap[contextId];
  }

  static SplayTreeMap<int, KrakenController?> getControllerMap() {
    return _controllerMap;
  }

  static KrakenController? getControllerOfName(String name) {
    if (!_nameIdMap.containsKey(name)) return null;
    int? contextId = _nameIdMap[name];
    return getControllerOfJSContextId(contextId);
  }

  WidgetDelegate? widgetDelegate;

  KrakenBundle? bundle;

  LoadHandler? onLoad;

  // Error handler when load bundle failed.
  LoadErrorHandler? onLoadError;

  // Error handler when got javascript error when evaluate javascript codes.
  JSErrorHandler? onJSError;

  final DevToolsService? devToolsService;
  final HttpClientInterceptor? httpClientInterceptor;

  KrakenMethodChannel? _methodChannel;

  KrakenMethodChannel? get methodChannel => _methodChannel;

  String? _name;
  String? get name => _name;
  set name(String? value) {
    if (value == null) return;
    if (_name != null) {
      int? contextId = _nameIdMap[_name];
      _nameIdMap.remove(_name);
      _nameIdMap[value] = contextId!;
    }
    _name = value;
  }

  final GestureListener? _gestureListener;

  KrakenController(
    String? name,
    double viewportWidth,
    double viewportHeight, {
    bool showPerformanceOverlay = false,
    enableDebug = false,
    Color? background,
    GestureListener? gestureListener,
    KrakenNavigationDelegate? navigationDelegate,
    KrakenMethodChannel? methodChannel,
    this.widgetDelegate,
    this.bundle,
    this.onLoad,
    this.onLoadError,
    this.onJSError,
    this.httpClientInterceptor,
    this.devToolsService,
    this.uriParser
  })  : _name = name,
        _gestureListener = gestureListener {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CONTROLLER_PROPERTY_INIT);
      PerformanceTiming.instance().mark(PERF_VIEW_CONTROLLER_INIT_START);
    }

    _methodChannel = methodChannel;
    KrakenMethodChannel.setJSMethodCallCallback(this);

    _view = KrakenViewController(viewportWidth, viewportHeight,
        background: background,
        showPerformanceOverlay: showPerformanceOverlay,
        enableDebug: enableDebug,
        rootController: this,
        navigationDelegate: navigationDelegate ?? KrakenNavigationDelegate(),
        gestureListener: _gestureListener,
        widgetDelegate: widgetDelegate,
    );

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_VIEW_CONTROLLER_INIT_END);
    }

    final int contextId = _view.contextId;

    _module = KrakenModuleController(this, contextId);

    if (bundle != null) {
      HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
      historyModule.bundle = bundle!;
    }

    assert(!_controllerMap.containsKey(contextId),
        'found exist contextId of KrakenController, contextId: $contextId');
    _controllerMap[contextId] = this;
    assert(!_nameIdMap.containsKey(name), 'found exist name of KrakenController, name: $name');
    if (name != null) {
      _nameIdMap[name] = contextId;
    }

    setupHttpOverrides(httpClientInterceptor, contextId: contextId);

    uriParser ??= UriParser();

    if (devToolsService != null) {
      devToolsService!.init(this);
    }
  }

  late KrakenViewController _view;

  KrakenViewController get view {
    return _view;
  }

  late KrakenModuleController _module;

  KrakenModuleController get module {
    return _module;
  }

  final Queue<HistoryItem> previousHistoryStack = Queue();
  final Queue<HistoryItem> nextHistoryStack = Queue();

  Uri get referrer {
    if (bundle is NetworkBundle) {
      return Uri.parse(href);
    } else if (bundle is AssetsBundle) {
      return Directory(href).uri;
    } else {
      return fallbackBundleUri(_view.contextId);
    }
  }

  static Uri fallbackBundleUri(int id) {
    // The fallback origin uri, like `vm://bundle/0`
    return Uri(scheme: 'vm', host: 'bundle', path: '$id');
  }

  void setNavigationDelegate(KrakenNavigationDelegate delegate) {
    _view.navigationDelegate = delegate;
  }

  Future<void> unload() async {
    assert(!_view._disposed, 'Kraken have already disposed');
    RenderObject root = _view.getRootRenderObject();
    RenderObject? parent = root.parent as RenderObject?;
    RenderObject? previousSibling;
    if (parent is ContainerRenderObjectMixin) {
      previousSibling = (root.parentData as ContainerParentDataMixin).previousSibling;
    }
    _module.dispose();
    _view.detachView();

    // Should clear previous page cached ui commands
    clearUICommand(_view.contextId);

    // Wait for next microtask to make sure C++ native Elements are GC collected and generate disposeEventTarget command in the command queue.
    Completer completer = Completer();
    Future.microtask(() {
      disposeContext(_view.contextId);

      // DisposeEventTarget command will created when js context disposed, should flush them before creating new view.
      flushUICommand();

      allocateNewContext(_view.contextId);

      _view = KrakenViewController(view._elementManager.viewportWidth, view._elementManager.viewportHeight,
          background: _view.background,
          showPerformanceOverlay: _view.showPerformanceOverlay,
          enableDebug: _view.enableDebug,
          contextId: _view.contextId,
          rootController: this,
          navigationDelegate: _view.navigationDelegate);
      _view.attachView(parent!, previousSibling);

      _module = KrakenModuleController(this, _view.contextId);

      completer.complete();
    });

    return completer.future;
  }

  String get href {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    return historyModule.href;
  }

  set href(String value) {
    _addHistory(KrakenBundle.fromUrl(value));
  }

  _addHistory(KrakenBundle bundle) {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    historyModule.bundle = bundle;
  }

  // reload current kraken view.
  Future<void> reload({ String? url }) async {
    assert(!_view._disposed, 'Kraken have already disposed');

    if (devToolsService != null) {
      devToolsService!.willReload();
    }

    await unload();
    await loadBundle(bundle: KrakenBundle.fromUrl(url ?? href));
    await evalBundle();

    if (devToolsService != null) {
      devToolsService!.didReload();
    }
  }

  void dispose() {
    _view.dispose();
    _module.dispose();
    _controllerMap[_view.contextId] = null;
    _controllerMap.remove(_view.contextId);
    _nameIdMap.remove(name);

    if (devToolsService != null) {
      devToolsService!.dispose();
    }
  }

  @deprecated
  String? get bundlePath => href;

  @deprecated
  set bundlePath(String? value) {
    if (value == null) return;
    // Set bundlePath should set the path to history module.
    href = value;
  }

  @deprecated
  String? get bundleURL => href;

  @deprecated
  set bundleURL(String? value) {
    if (value == null) return;
    // Set bundleURL should set the url to history module.
    href = value;
  }

  String get origin => Uri.parse(href).origin;

  // preload javascript source and cache it.
  Future<void> loadBundle({
    KrakenBundle? bundle
  }) async {
    assert(!_view._disposed, 'Kraken have already disposed');

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_LOAD_START);
    }

    // Load bundle need push curret href to history.
    if (bundle != null) {
      String? url = bundle.uri.toString().isEmpty ? (getBundleURLFromEnv() ?? getBundlePathFromEnv()) : href;
      if (url == null && methodChannel is KrakenNativeChannel) {
        url = await (methodChannel as KrakenNativeChannel).getUrl();
      }
      _addHistory(bundle);
      this.bundle = bundle;
    }

    if (onLoadError != null) {
      try {
        await bundle?.resolve(view.contextId);
      } catch (e, stack) {
        onLoadError!(FlutterError(e.toString()), stack);
      }
    } else {
      await bundle?.resolve(view.contextId);
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_LOAD_END);
    }
  }

  // execute preloaded javascript source
  Future<void> evalBundle() async {
    assert(!_view._disposed, 'Kraken have already disposed');
    if (bundle != null) {
      await bundle!.eval(_view.contextId);
      // trigger DOMContentLoaded event
      module.requestAnimationFrame((_) {
        Event event = Event(EVENT_DOM_CONTENT_LOADED);
        EventTarget? window = view.getEventTargetById(WINDOW_ID);
        if (window != null) {
          window.dispatchEvent(event);
          // @HACK: window.load should trigger after all image had loaded.
          // Someone needs to fix this in the future.
          module.requestAnimationFrame((_) {
            Event event = Event(EVENT_LOAD);
            window.dispatchEvent(event);
          });
        }
      });

      if (onLoad != null) {
        // DOM element are created at next frame, so we should trigger onload callback in the next frame.
        module.requestAnimationFrame((_) {
          onLoad!(this);
        });
      }

    }
  }
}

mixin RenderObjectWithControllerMixin {
  // Kraken controller reference which control all kraken created renderObjects.
  KrakenController? controller;
}
