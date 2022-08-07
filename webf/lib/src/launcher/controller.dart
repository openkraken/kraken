/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart' show RenderObjectElement;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' show RouteInformation, WidgetsBinding, WidgetsBindingObserver, AnimationController;
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/gesture.dart';
import 'package:webf/module.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

const int WINDOW_ID = -1;
const int DOCUMENT_ID = -2;

// Error handler when load bundle failed.
typedef LoadHandler = void Function(WebFController controller);
typedef LoadErrorHandler = void Function(FlutterError error, StackTrace stack);
typedef JSErrorHandler = void Function(String message);
typedef JSLogHandler = void Function(int level, String message);
typedef PendingCallback = void Function();

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
  void init(WebFController controller);
  void willReload();
  void didReload();
  void dispose();
}

// An kraken View Controller designed for multiple kraken view control.
class WebFViewController implements WidgetsBindingObserver, ElementsBindingObserver {
  static Map<int, Pointer<NativeBindingObject>> documentNativePtrMap = {};
  static Map<int, Pointer<NativeBindingObject>> windowNativePtrMap = {};

  WebFController rootController;

  // The methods of the KrakenNavigateDelegation help you implement custom behaviors that are triggered
  // during a kraken view's process of loading, and completing a navigation request.
  WebFNavigationDelegate? navigationDelegate;

  GestureListener? gestureListener;

  double _viewportWidth;
  double get viewportWidth => _viewportWidth;
  set viewportWidth(double value) {
    if (value != _viewportWidth) {
      _viewportWidth = value;
      viewport.viewportSize = ui.Size(_viewportWidth, _viewportHeight);
    }
  }

  double _viewportHeight;
  double get viewportHeight => _viewportHeight;
  set viewportHeight(double value) {
    if (value != _viewportHeight) {
      _viewportHeight = value;
      viewport.viewportSize = ui.Size(_viewportWidth, _viewportHeight);
    }
  }

  Color? background;

  WidgetDelegate? widgetDelegate;

  WebFViewController(this._viewportWidth, this._viewportHeight,
      {this.background,
      this.enableDebug = false,
      int? contextId,
      required this.rootController,
      this.navigationDelegate,
      this.gestureListener,
      this.widgetDelegate,
      // Viewport won't change when kraken page reload, should reuse previous page's viewportBox.
      RenderViewportBox? originalViewport}) {
    if (enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_VIEW_CONTROLLER_PROPERTY_INIT);
      PerformanceTiming.instance().mark(PERF_BRIDGE_INIT_START);
    }
    BindingBridge.setup();
    _contextId = contextId ?? initBridge();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_BRIDGE_INIT_END);
      PerformanceTiming.instance().mark(PERF_CREATE_VIEWPORT_START);
    }

    if (originalViewport != null) {
      // Should update to new controller.
      originalViewport.controller = rootController;
      viewport = originalViewport;
    } else {
      viewport = RenderViewportBox(background: background, viewportSize: ui.Size(viewportWidth, viewportHeight), controller: rootController);
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_VIEWPORT_END);
      PerformanceTiming.instance().mark(PERF_ELEMENT_MANAGER_INIT_START);
    }

    _setupObserver();

    defineBuiltInElements();

    document = Document(
      BindingContext(_contextId, documentNativePtrMap[_contextId]!),
      viewport: viewport,
      controller: rootController,
      gestureListener: gestureListener,
      widgetDelegate: widgetDelegate,
    );
    _setEventTarget(DOCUMENT_ID, document);

    window = Window(BindingContext(_contextId, windowNativePtrMap[_contextId]!), document);
    _registerPlatformBrightnessChange();
    _setEventTarget(WINDOW_ID, window);

    // Listeners need to be registered to window in order to dispatch events on demand.
    if (gestureListener != null) {
      GestureListener listener = gestureListener!;
      if (listener.onTouchStart != null) {
        document.addEventListener(EVENT_TOUCH_START, (Event event) => listener.onTouchStart!(event as TouchEvent));
      }

      if (listener.onTouchMove != null) {
        document.addEventListener(EVENT_TOUCH_MOVE, (Event event) => listener.onTouchMove!(event as TouchEvent));
      }

      if (listener.onTouchEnd != null) {
        document.addEventListener(EVENT_TOUCH_END, (Event event) => listener.onTouchEnd!(event as TouchEvent));
      }

      if (listener.onDrag != null) {
        document.addEventListener(EVENT_DRAG, (Event event) => listener.onDrag!(event as GestureEvent));
      }
    }

    // Blur input element when new input focused.
    window.addEventListener(EVENT_CLICK, (event) {
      if (event.target is Element) {
        Element? focusedElement = document.focusedElement;
        if (focusedElement != null && focusedElement != event.target) {
          document.focusedElement!.blur();
        }
        (event.target as Element).focus();
      }
    });

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ELEMENT_MANAGER_INIT_END);
    }
  }

  // Index value which identify javascript runtime context.
  late int _contextId;
  int get contextId => _contextId;

  // Enable print debug message when rendering.
  bool enableDebug;

  // Kraken have already disposed.
  bool _disposed = false;

  bool get disposed => _disposed;

  late RenderViewportBox viewport;
  late Document document;
  late Window window;

  void evaluateJavaScripts(String code) {
    assert(!_disposed, 'WebF have already disposed');
    evaluateScripts(_contextId, code);
  }

  void _setupObserver() {
    if (ElementsBinding.instance != null) {
      ElementsBinding.instance!.addObserver(this);
    } else {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  void _teardownObserver() {
    if (ElementsBinding.instance != null) {
      ElementsBinding.instance!.removeObserver(this);
    } else {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  // Attach kraken's renderObject to an renderObject.
  void attachTo(RenderObject parent, [RenderObject? previousSibling]) {
    if (parent is ContainerRenderObjectMixin) {
      parent.insert(document.renderer!, after: previousSibling);
    } else if (parent is RenderObjectWithChildMixin) {
      parent.child = document.renderer;
    }
  }

  // Dispose controller and recycle all resources.
  void dispose() {
    // FIXME: for break circle reference
    viewport.controller = null;

    debugDOMTreeChanged = null;

    _teardownObserver();
    _unregisterPlatformBrightnessChange();

    // Should clear previous page cached ui commands
    clearUICommand(_contextId);

    disposePage(_contextId);

    _clearTargets();

    document.dispose();
    window.dispose();
    _disposed = true;
  }

  VoidCallback? _originalOnPlatformBrightnessChanged;

  void _registerPlatformBrightnessChange() {
    _originalOnPlatformBrightnessChanged = ui.window.onPlatformBrightnessChanged;
    ui.window.onPlatformBrightnessChanged = _onPlatformBrightnessChanged;
  }

  void _unregisterPlatformBrightnessChange() {
    ui.window.onPlatformBrightnessChanged = _originalOnPlatformBrightnessChanged;
    _originalOnPlatformBrightnessChanged = null;
  }

  void _onPlatformBrightnessChanged() {
    if (_originalOnPlatformBrightnessChanged != null) {
      _originalOnPlatformBrightnessChanged!();
    }
    window.dispatchEvent(ColorSchemeChangeEvent(window.colorScheme));
  }

  Map<int, EventTarget> _eventTargets = <int, EventTarget>{};

  T? getEventTargetById<T>(int targetId) {
    return _getEventTargetById(targetId);
  }

  int? getTargetIdByEventTarget(EventTarget eventTarget) {
    if (_eventTargets.containsValue(eventTarget)) {
      for (var entry in _eventTargets.entries) {
        if (entry.value == eventTarget) {
          return entry.key;
        }
      }
    }
    return null;
  }

  // Save all WidgetElement to manager life cycle.
  final List<WidgetElement> _widgetElements = [];

  void deactivateWidgetElements() {
    _widgetElements.forEach((element) {
      element.deactivate();
    });
  }

  void addWidgetElement(WidgetElement widgetElement) {
    _widgetElements.add(widgetElement);
  }

  void _removeWidgetElement(WidgetElement widgetElement) {
    _widgetElements.remove(widgetElement);
  }

  T? _getEventTargetById<T>(int targetId) {
    EventTarget? target = _eventTargets[targetId];
    if (target is T)
      return target as T;
    else
      return null;
  }

  bool _existsTarget(int id) {
    return _eventTargets.containsKey(id);
  }

  void _removeTarget(int targetId) {
    if (_eventTargets.containsKey(targetId)) {
      EventTarget? target = _eventTargets.remove(targetId);

      if (target is WidgetElement) {
        _removeWidgetElement(target);
      }
    }
  }

  void _setEventTarget(int targetId, EventTarget target) {
    _eventTargets[targetId] = target;
  }

  void _clearTargets() {
    // Set current eventTargets to a new object, clean old targets by gc.
    _eventTargets = <int, EventTarget>{};
    _widgetElements.clear();
  }

  // export Uint8List bytes from rendered result.
  Future<Uint8List> toImage(double devicePixelRatio, [int? eventTargetId]) {
    assert(!_disposed, 'WebF have already disposed');
    Completer<Uint8List> completer = Completer();
    try {
      if (eventTargetId != null && !_existsTarget(eventTargetId)) {
        String msg = 'toImage: unknown node id: $eventTargetId';
        completer.completeError(Exception(msg));
        return completer.future;
      }
      var node = eventTargetId == null ? document.documentElement : _getEventTargetById<EventTarget>(eventTargetId);
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

  void createElement(int targetId, Pointer<NativeBindingObject> nativePtr, String tagName) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_ELEMENT_START, uniqueId: targetId);
    }
    assert(!_existsTarget(targetId), 'ERROR: Can not create element with same id "$targetId"');
    Element element = document.createElement(tagName.toUpperCase(), BindingContext(_contextId, nativePtr));
    _setEventTarget(targetId, element);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_ELEMENT_END, uniqueId: targetId);
    }
  }

  void createTextNode(int targetId, Pointer<NativeBindingObject> nativePtr, String data) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_TEXT_NODE_START, uniqueId: targetId);
    }
    TextNode textNode = document.createTextNode(data, BindingContext(_contextId, nativePtr));
    _setEventTarget(targetId, textNode);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_TEXT_NODE_END, uniqueId: targetId);
    }
  }

  void createComment(int targetId, Pointer<NativeBindingObject> nativePtr) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_COMMENT_START, uniqueId: targetId);
    }
    Comment comment = document.createComment(BindingContext(_contextId, nativePtr));
    _setEventTarget(targetId, comment);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_COMMENT_END, uniqueId: targetId);
    }
  }

  void createDocumentFragment(int targetId, Pointer<NativeBindingObject> nativePtr) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_DOCUMENT_FRAGMENT_START, uniqueId: targetId);
    }
    DocumentFragment fragment = document.createDocumentFragment(BindingContext(_contextId, nativePtr));
    _setEventTarget(targetId, fragment);
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CREATE_DOCUMENT_FRAGMENT_END, uniqueId: targetId);
    }
  }

  void addEvent(int targetId, String eventType) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ADD_EVENT_START, uniqueId: targetId);
    }
    if (!_existsTarget(targetId)) return;
    EventTarget? target = _getEventTargetById<EventTarget>(targetId);
    if (target != null) {
      BindingBridge.listenEvent(target, eventType);
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ADD_EVENT_END, uniqueId: targetId);
    }
  }

  void removeEvent(int targetId, String eventType) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_REMOVE_EVENT_START, uniqueId: targetId);
    }
    assert(_existsTarget(targetId), 'targetId: $targetId event: $eventType');

    EventTarget? target = _getEventTargetById<EventTarget>(targetId);
    if (target != null) {
      BindingBridge.unlistenEvent(target, eventType);
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_REMOVE_EVENT_END, uniqueId: targetId);
    }
  }

  void cloneNode(int originalId, int newId) {
    EventTarget originalTarget = _getEventTargetById(originalId)!;
    EventTarget newTarget = _getEventTargetById(newId)!;

    // Current only element clone will process in dart.
    if (originalTarget is Element) {
      Element newElement = newTarget as Element;
      // Copy inline style.
      originalTarget.inlineStyle.forEach((key, value) {
        newElement.setInlineStyle(key, value);
      });
      // Copy element attributes.
      originalTarget.attributes.forEach((key, value) {
        newElement.setAttribute(key, value);
      });
    }
  }

  void removeNode(int targetId) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_REMOVE_NODE_START, uniqueId: targetId);
    }

    assert(_existsTarget(targetId), 'targetId: $targetId');

    Node target = _getEventTargetById<Node>(targetId)!;
    target.parentNode?.removeChild(target);

    _debugDOMTreeChanged();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_REMOVE_NODE_END, uniqueId: targetId);
    }
  }

  /// <!-- beforebegin -->
  /// <p>
  ///   <!-- afterbegin -->
  ///   foo
  ///   <!-- beforeend -->
  /// </p>
  /// <!-- afterend -->
  void insertAdjacentNode(int targetId, String position, int newTargetId) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_INSERT_ADJACENT_NODE_START, uniqueId: targetId);
    }

    assert(_existsTarget(targetId), 'targetId: $targetId position: $position newTargetId: $newTargetId');
    assert(_existsTarget(newTargetId), 'newTargetId: $newTargetId position: $position');

    Node target = _getEventTargetById<Node>(targetId)!;
    Node newNode = _getEventTargetById<Node>(newTargetId)!;
    Node? targetParentNode = target.parentNode;

    switch (position) {
      case 'beforebegin':
        targetParentNode!.insertBefore(newNode, target);
        break;
      case 'afterbegin':
        target.insertBefore(newNode, target.firstChild);
        break;
      case 'beforeend':
        target.appendChild(newNode);
        break;
      case 'afterend':
        if (targetParentNode!.lastChild == target) {
          targetParentNode.appendChild(newNode);
        } else {
          targetParentNode.insertBefore(
            newNode,
            targetParentNode.childNodes[targetParentNode.childNodes.indexOf(target) + 1],
          );
        }
        break;
    }

    _debugDOMTreeChanged();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_INSERT_ADJACENT_NODE_END, uniqueId: targetId);
    }
  }

  void setAttribute(int targetId, String key, String value) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_PROPERTIES_START, uniqueId: targetId);
    }

    assert(_existsTarget(targetId), 'targetId: $targetId key: $key value: $value');
    Node target = _getEventTargetById<Node>(targetId)!;

    if (target is Element) {
      // Only element has properties.
      target.setAttribute(key, value);
    } else if (target is TextNode && (key == 'data' || key == 'nodeValue')) {
      target.data = value;
    } else {
      debugPrint('Only element has properties, try setting $key to Node(#$targetId).');
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_PROPERTIES_END, uniqueId: targetId);
    }
  }

  @deprecated
  getProperty(int targetId, String key) {
    return getAttribute(targetId, key);
  }

  String? getAttribute(int targetId, String key) {
    assert(_existsTarget(targetId), 'targetId: $targetId key: $key');
    Node target = _getEventTargetById<Node>(targetId)!;

    if (target is Element) {
      // Only element has attributes.
      return target.getAttribute(key);
    } else if (target is TextNode && (key == 'data' || key == 'nodeValue')) {
      // @TODO: property is not attribute.
      return target.data;
    } else {
      return null;
    }
  }

  @deprecated
  void removeProperty(int targetId, String key) {
    removeAttribute(targetId, key);
  }

  void removeAttribute(int targetId, String key) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_PROPERTIES_START, uniqueId: targetId);
    }
    assert(_existsTarget(targetId), 'targetId: $targetId key: $key');
    Node target = _getEventTargetById<Node>(targetId)!;

    if (target is Element) {
      target.removeAttribute(key);
    } else if (target is TextNode && (key == 'data' || key == 'nodeValue')) {
      // @TODO: property is not attribute.
      target.data = '';
    } else {
      debugPrint('Only element has attributes, try removing $key from Node(#$targetId).');
    }
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_PROPERTIES_END, uniqueId: targetId);
    }
  }

  void setInlineStyle(int targetId, String key, String value) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_STYLE_START, uniqueId: targetId);
    }
    assert(_existsTarget(targetId), 'id: $targetId key: $key value: $value');
    Node? target = _getEventTargetById<Node>(targetId);
    if (target == null) return;

    if (target is Element) {
      target.setInlineStyle(key, value);
    } else {
      debugPrint('Only element has style, try setting style.$key from Node(#$targetId).');
    }
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SET_STYLE_END, uniqueId: targetId);
    }
  }

  void flushPendingStyleProperties(int targetId) {
    if (!_existsTarget(targetId)) return;
    Node? target = _getEventTargetById<Node>(targetId);
    if (target == null) return;

    if (target is Element) {
      target.style.flushPendingProperties();
    } else {
      debugPrint('Only element has style, try flushPendingStyleProperties from Node(#$targetId).');
    }
  }

  // Hooks for DevTools.
  VoidCallback? debugDOMTreeChanged;
  void _debugDOMTreeChanged() {
    VoidCallback? f = debugDOMTreeChanged;
    if (f != null) {
      f();
    }
  }

  Future<void> handleNavigationAction(String? sourceUrl, String targetUrl, WebFNavigationType navigationType) async {
    WebFNavigationAction action = WebFNavigationAction(sourceUrl, targetUrl, navigationType);

    WebFNavigationDelegate _delegate = navigationDelegate!;

    try {
      WebFNavigationActionPolicy policy = await _delegate.dispatchDecisionHandler(action);
      if (policy == WebFNavigationActionPolicy.cancel) return;

      switch (action.navigationType) {
        case WebFNavigationType.navigate:
          await rootController.load(WebFBundle.fromUrl(action.target));
          break;
        case WebFNavigationType.reload:
          await rootController.reload();
          break;
        default:
        // Navigate and other type, do nothing.
      }
    } catch (e, stack) {
      if (_delegate.errorHandler != null) {
        _delegate.errorHandler!(e, stack);
      } else {
        print('WebF navigation failed: $e\n$stack');
      }
    }
  }

  // Call from JS Bridge before JS side eventTarget object been Garbage collected.
  void disposeEventTarget(int targetId) {
    Node? target = _getEventTargetById<Node>(targetId);
    if (target == null) return;

    _removeTarget(targetId);
    target.dispose();
  }

  RenderObject getRootRenderObject() {
    return viewport;
  }

  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // TODO: implement didChangeLocales
  }

  ui.WindowPadding _prevViewInsets = ui.window.viewInsets;
  static double FOCUS_VIEWINSET_BOTTOM_OVERALL = 32;

  @override
  void didChangeMetrics() {
    double bottomInset = ui.window.viewInsets.bottom / ui.window.devicePixelRatio;
    if (_prevViewInsets.bottom > ui.window.viewInsets.bottom) {
      // Hide keyboard
      viewport.bottomInset = bottomInset;
    } else {
      bool shouldScrollByToCenter = false;
      Element? focusedElement = document.focusedElement;
      if (focusedElement != null) {
        RenderBox? renderer = focusedElement.renderer;
        if (renderer != null && renderer.hasSize) {
          Offset focusOffset = renderer.localToGlobal(Offset.zero);
          // FOCUS_VIEWINSET_BOTTOM_OVERALL to meet border case.
          if (focusOffset.dy > viewportHeight - bottomInset - FOCUS_VIEWINSET_BOTTOM_OVERALL) {
            shouldScrollByToCenter = true;
          }
        }
      }
      // Show keyboard
      viewport.bottomInset = bottomInset;
      if (shouldScrollByToCenter) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          window.scrollBy(0, bottomInset);
        });
      }
    }
    _prevViewInsets = ui.window.viewInsets;
  }

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
  }

  @override
  void didChangeTextScaleFactor() {
    // TODO: implement didChangeTextScaleFactor
  }

  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
  }

  @override
  Future<bool> didPopRoute() async {
    // TODO: implement didPopRoute
    return false;
  }

  @override
  Future<bool> didPushRoute(String route) async {
    // TODO: implement didPushRoute
    return false;
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    // TODO: implement didPushRouteInformation
    return false;
  }
}

// An controller designed to control kraken's functional modules.
class WebFModuleController with TimerMixin, ScheduleFrameMixin {
  late ModuleManager _moduleManager;
  ModuleManager get moduleManager => _moduleManager;

  WebFModuleController(WebFController controller, int contextId) {
    _moduleManager = ModuleManager(controller, contextId);
  }

  void dispose() {
    disposeTimer();
    disposeScheduleFrame();
    _moduleManager.dispose();
  }
}

class WebFController {
  static final SplayTreeMap<int, WebFController?> _controllerMap = SplayTreeMap();
  static final Map<String, int> _nameIdMap = {};

  UriParser? uriParser;

  late RenderObjectElement rootFlutterElement;

  static WebFController? getControllerOfJSContextId(int? contextId) {
    if (!_controllerMap.containsKey(contextId)) {
      return null;
    }

    return _controllerMap[contextId];
  }

  static SplayTreeMap<int, WebFController?> getControllerMap() {
    return _controllerMap;
  }

  static WebFController? getControllerOfName(String name) {
    if (!_nameIdMap.containsKey(name)) return null;
    int? contextId = _nameIdMap[name];
    return getControllerOfJSContextId(contextId);
  }

  GestureDispatcher gestureDispatcher = GestureDispatcher();

  WidgetDelegate? widgetDelegate;

  LoadHandler? onLoad;

  // Error handler when load bundle failed.
  LoadErrorHandler? onLoadError;

  // Error handler when got javascript error when evaluate javascript codes.
  JSErrorHandler? onJSError;

  final DevToolsService? devToolsService;
  final HttpClientInterceptor? httpClientInterceptor;

  WebFMethodChannel? _methodChannel;

  WebFMethodChannel? get methodChannel => _methodChannel;

  JSLogHandler? _onJSLog;
  JSLogHandler? get onJSLog => _onJSLog;
  set onJSLog(JSLogHandler? jsLogHandler) {
    _onJSLog = jsLogHandler;
  }

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

  // The kraken view entrypoint bundle.
  WebFBundle? _entrypoint;

  WebFController(
    String? name,
    double viewportWidth,
    double viewportHeight, {
    bool showPerformanceOverlay = false,
    bool enableDebug = false,
    bool autoExecuteEntrypoint = true,
    Color? background,
    GestureListener? gestureListener,
    WebFNavigationDelegate? navigationDelegate,
    WebFMethodChannel? methodChannel,
    WebFBundle? entrypoint,
    this.widgetDelegate,
    this.onLoad,
    this.onLoadError,
    this.onJSError,
    this.httpClientInterceptor,
    this.devToolsService,
    this.uriParser,
  })  : _name = name,
        _entrypoint = entrypoint,
        _gestureListener = gestureListener {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_CONTROLLER_PROPERTY_INIT);
      PerformanceTiming.instance().mark(PERF_VIEW_CONTROLLER_INIT_START);
    }

    _methodChannel = methodChannel;
    WebFMethodChannel.setJSMethodCallCallback(this);

    _view = WebFViewController(
      viewportWidth,
      viewportHeight,
      background: background,
      enableDebug: enableDebug,
      rootController: this,
      navigationDelegate: navigationDelegate ?? WebFNavigationDelegate(),
      gestureListener: _gestureListener,
      widgetDelegate: widgetDelegate,
    );

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_VIEW_CONTROLLER_INIT_END);
    }

    final int contextId = _view.contextId;

    _module = WebFModuleController(this, contextId);

    if (entrypoint != null) {
      HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
      historyModule.add(entrypoint);
    }

    assert(!_controllerMap.containsKey(contextId), 'found exist contextId of WebFController, contextId: $contextId');
    _controllerMap[contextId] = this;
    assert(!_nameIdMap.containsKey(name), 'found exist name of WebFController, name: $name');
    if (name != null) {
      _nameIdMap[name] = contextId;
    }

    setupHttpOverrides(httpClientInterceptor, contextId: contextId);

    uriParser ??= UriParser();

    if (devToolsService != null) {
      devToolsService!.init(this);
    }

    if (autoExecuteEntrypoint) {
      executeEntrypoint();
    }
  }

  late WebFViewController _view;

  WebFViewController get view {
    return _view;
  }

  late WebFModuleController _module;

  WebFModuleController get module {
    return _module;
  }

  final Queue<HistoryItem> previousHistoryStack = Queue();
  final Queue<HistoryItem> nextHistoryStack = Queue();

  static Uri fallbackBundleUri([int? id]) {
    // The fallback origin uri, like `vm://bundle/0`
    return Uri(scheme: 'vm', host: 'bundle', path: id != null ? '$id' : null);
  }

  void setNavigationDelegate(WebFNavigationDelegate delegate) {
    _view.navigationDelegate = delegate;
  }

  Future<void> unload() async {
    assert(!_view._disposed, 'WebF have already disposed');
    // Should clear previous page cached ui commands
    clearUICommand(_view.contextId);

    // Wait for next microtask to make sure C++ native Elements are GC collected.
    Completer completer = Completer();
    Future.microtask(() {
      _module.dispose();
      _view.dispose();

      allocateNewPage(_view.contextId);

      _view = WebFViewController(view.viewportWidth, view.viewportHeight,
          background: _view.background,
          enableDebug: _view.enableDebug,
          contextId: _view.contextId,
          rootController: this,
          navigationDelegate: _view.navigationDelegate,
          gestureListener: _view.gestureListener,
          widgetDelegate: _view.widgetDelegate,
          originalViewport: _view.viewport);

      _module = WebFModuleController(this, _view.contextId);

      completer.complete();
    });

    return completer.future;
  }

  String? get _url {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    return historyModule.stackTop?.url;
  }

  String get url => _url ?? '';

  _addHistory(WebFBundle bundle) {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    historyModule.add(bundle);
  }

  Future<void> reload() async {
    assert(!_view._disposed, 'WebF have already disposed');

    if (devToolsService != null) {
      devToolsService!.willReload();
    }

    await unload();
    await executeEntrypoint();

    if (devToolsService != null) {
      devToolsService!.didReload();
    }
  }

  Future<void> load(WebFBundle bundle) async {
    assert(!_view._disposed, 'WebF have already disposed');

    if (devToolsService != null) {
      devToolsService!.willReload();
    }

    await unload();

    // Update entrypoint.
    _entrypoint = bundle;
    _addHistory(bundle);

    await executeEntrypoint();

    if (devToolsService != null) {
      devToolsService!.didReload();
    }
  }

  String? getResourceContent(String? url) {
    WebFBundle? entrypoint = _entrypoint;
    if (url == this.url && entrypoint != null && entrypoint.isResolved) {
      return utf8.decode(entrypoint.data!);
    }
    return null;
  }

  bool _paused = false;
  bool get paused => _paused;

  final List<PendingCallback> _pendingCallbacks = [];

  void pushPendingCallbacks(PendingCallback callback) {
    _pendingCallbacks.add(callback);
  }

  void flushPendingCallbacks() {
    for (int i = 0; i < _pendingCallbacks.length; i++) {
      _pendingCallbacks[i]();
    }
    _pendingCallbacks.clear();
  }

  // Pause all timers and callbacks if kraken page are invisible.
  void pause() {
    _paused = true;
    module.pauseInterval();
  }

  // Resume all timers and callbacks if kraken page now visible.
  void resume() {
    _paused = false;
    flushPendingCallbacks();
    module.resumeInterval();
  }

  void dispose() {
    _view.dispose();
    _module.dispose();
    _controllerMap[_view.contextId] = null;
    _controllerMap.remove(_view.contextId);
    _nameIdMap.remove(name);

    devToolsService?.dispose();
  }

  String get origin => Uri.parse(url).origin;

  Future<void> executeEntrypoint({bool shouldResolve = true, bool shouldEvaluate = true, AnimationController? animationController}) async {
    if (_entrypoint != null && shouldResolve) {
      await _resolveEntrypoint();
      if (_entrypoint!.isResolved && shouldEvaluate) {
        _evaluateEntrypoint(animationController: animationController);
      } else {
        throw FlutterError('Unable to resolve $_entrypoint');
      }
    } else {
      throw FlutterError('Entrypoint is empty.');
    }
  }

  // Resolve the entrypoint bundle.
  // In general you should use executeEntrypoint, which including resolving and evaluating.
  Future<void> _resolveEntrypoint() async {
    assert(!_view._disposed, 'WebF have already disposed');

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_LOAD_START);
    }

    WebFBundle? bundleToLoad = _entrypoint;
    if (bundleToLoad == null) {
      // Do nothing if bundle is null.
      return;
    }

    // Resolve the bundle, including network download or other fetching ways.
    try {
      await bundleToLoad.resolve(view.contextId);
    } catch (e, stack) {
      if (onLoadError != null) {
        onLoadError!(FlutterError(e.toString()), stack);
      }
      // Not to dismiss this error.
      rethrow;
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_JS_BUNDLE_LOAD_END);
    }
  }

  // Execute the content from entrypoint bundle.
  void _evaluateEntrypoint({AnimationController? animationController}) async {
    // @HACK: Execute JavaScript scripts will block the Flutter UI Threads.
    // Listen for animationController listener to make sure to execute Javascript after route transition had completed.
    if (animationController != null) {
      animationController.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _evaluateEntrypoint();
        }
      });
      return;
    }

    assert(!_view._disposed, 'WebF have already disposed');
    if (_entrypoint != null) {
      WebFBundle entrypoint = _entrypoint!;
      int contextId = _view.contextId;
      assert(entrypoint.isResolved, 'The webf bundle $entrypoint is not resolved to evaluate.');

      if (kProfileMode) {
        PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_START);
      }

      // entry point start parse.
      _view.document.parsing = true;

      Uint8List data = entrypoint.data!;
      if (entrypoint.isJavascript) {
        // Prefer sync decode in loading entrypoint.
        evaluateScripts(contextId, await resolveStringFromData(data, preferSync: true), url: url);
      } else if (entrypoint.isBytecode) {
        evaluateQuickjsByteCode(contextId, data);
      } else if (entrypoint.isHTML) {
        parseHTML(contextId, await resolveStringFromData(data));
      } else if (entrypoint.contentType.primaryType == 'text') {
        // Fallback treating text content as JavaScript.
        try {
          evaluateScripts(contextId, await resolveStringFromData(data, preferSync: true), url: url);
        } catch (error) {
          print('Fallback to execute JavaScript content of $url');
          rethrow;
        }
      } else {
        // The resource type can not be evaluated.
        throw FlutterError('Can\'t evaluate content of $url');
      }

      // entry point end parse.
      _view.document.parsing = false;

      // Should check completed when parse end.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // UICommand list is read in the next frame, so we need to determine whether there are labels
        // such as images and scripts after it to check is completed.
        checkCompleted();
      });
      SchedulerBinding.instance.scheduleFrame();

      if (kProfileMode) {
        PerformanceTiming.instance().mark(PERF_JS_BUNDLE_EVAL_END);
      }

      // To release entrypoint bundle memory.
      entrypoint.dispose();

      // trigger DOMContentLoaded event
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Event event = Event(EVENT_DOM_CONTENT_LOADED);
        EventTarget window = view.window;
        window.dispatchEvent(event);
      });
      SchedulerBinding.instance.scheduleFrame();
    }
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/loader/FrameLoader.h#L470
  bool _isComplete = false;

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/loader/FrameLoader.cpp#L840
  // Check whether the document has been loaded, such as html has parsed (main of JS has evaled) and images/scripts has loaded.
  void checkCompleted() {
    if (_isComplete) return;

    // Are we still parsing?
    if (_view.document.parsing) return;

    // Still waiting for images/scripts?
    if (_view.document.hasPendingRequest) return;

    // Still waiting for elements that don't go through a FrameLoader?
    if (_view.document.isDelayingLoadEvent) return;

    // Any frame that hasn't completed yet?
    // TODO:

    _isComplete = true;

    _dispatchWindowLoadEvent();
  }

  void _dispatchWindowLoadEvent() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // DOM element are created at next frame, so we should trigger onload callback in the next frame.
      Event event = Event(EVENT_LOAD);
      _view.window.dispatchEvent(event);

      if (onLoad != null) {
        onLoad!(this);
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }
}

mixin RenderObjectWithControllerMixin {
  // Kraken controller reference which control all kraken created renderObjects.
  WebFController? controller;
}
