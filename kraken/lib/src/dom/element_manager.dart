/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:core';
import 'dart:ffi';
import 'dart:math' as math;
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding, WidgetsBindingObserver, RouteInformation;
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/src/dom/element_registry.dart' as element_registry;
import 'package:kraken/widget.dart';

const String UNKNOWN = 'UNKNOWN';

const int HTML_ID = -1;
const int WINDOW_ID = -2;
const int DOCUMENT_ID = -3;

typedef ElementCreator = Element Function(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager);

class ElementManager implements WidgetsBindingObserver, ElementsBindingObserver  {
  // Call from JS Bridge before JS side eventTarget object been Garbage collected.
  static void disposeEventTarget(int contextId, int id) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;
    EventTarget? eventTarget = controller.view.getEventTargetById(id);
    if (eventTarget == null) return;
    eventTarget.dispose();
    malloc.free(eventTarget.nativeEventTargetPtr);
  }

  // Alias defineElement export for kraken plugin
  static void defineElement(String type, ElementCreator creator) {
    element_registry.defineElement(type, creator);
  }

  static Map<int, Pointer<NativeEventTarget>> htmlNativePtrMap = {};
  static Map<int, Pointer<NativeEventTarget>> documentNativePtrMap = {};
  static Map<int, Pointer<NativeEventTarget>> windowNativePtrMap = {};

  static double FOCUS_VIEWINSET_BOTTOM_OVERALL = 32;
  // Single child renderView.
  late final RenderViewportBox viewport;
  late final Document document;
  late final Element viewportElement;
  Map<int, EventTarget> _eventTargets = <int, EventTarget>{};
  bool? showPerformanceOverlayOverride;
  KrakenController controller;

  double get viewportWidth => viewport.viewportSize.width;
  double get viewportHeight => viewport.viewportSize.height;

  final int contextId;

  final List<VoidCallback> _detachCallbacks = [];

  GestureListener? gestureListener;

  WidgetDelegate? widgetDelegate;

  ElementManager({
    required this.contextId,
    required this.viewport,
    required this.controller,
    this.showPerformanceOverlayOverride = false,
    this.gestureListener,
    this.widgetDelegate,
  }) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ELEMENT_MANAGER_PROPERTY_INIT);
      PerformanceTiming.instance().mark(PERF_ROOT_ELEMENT_INIT_START);
    }

    HTMLElement documentElement = HTMLElement(HTML_ID, htmlNativePtrMap[contextId]!, this);
    setEventTarget(documentElement);

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_ROOT_ELEMENT_INIT_END);
    }

    _setupObserver();

    Window window = Window(WINDOW_ID, windowNativePtrMap[contextId]!, this, viewportElement);
    setEventTarget(window);

    document = Document(DOCUMENT_ID, documentNativePtrMap[contextId]!, this, documentElement);
    setEventTarget(document);

    documentElement.attachTo(document);

    element_registry.defineBuiltInElements();

    // Listeners need to be registered to window in order to dispatch events on demand.
    if (gestureListener != null) {
      if (gestureListener!.onTouchStart != null) {
        window.addEvent(EVENT_TOUCH_START);
      }

      if (gestureListener!.onTouchMove != null) {
        window.addEvent(EVENT_TOUCH_MOVE);
      }

      if (gestureListener!.onTouchEnd != null) {
        window.addEvent(EVENT_TOUCH_END);
      }
    }
  }

  void _setupObserver() {
    if (ElementsBinding.instance != null) {
      ElementsBinding.instance!.addObserver(this);
    } else if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addObserver(this);
    }
  }

  void _teardownObserver() {
    if (ElementsBinding.instance != null) {
      ElementsBinding.instance!.removeObserver(this);
    } else if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.removeObserver(this);
    }
  }

  T? getEventTargetByTargetId<T>(int targetId) {
    EventTarget? target = _eventTargets[targetId];
    if (target is T)
      return target as T;
    else
      return null;
  }

  bool existsTarget(int id) {
    return _eventTargets.containsKey(id);
  }

  void removeTarget(EventTarget target) {
    if (_eventTargets.containsKey(target.targetId)) {
      _eventTargets.remove(target.targetId);
    }
  }

  void setDetachCallback(VoidCallback callback) {
    _detachCallbacks.add(callback);
  }

  void setEventTarget(EventTarget target) {
    _eventTargets[target.targetId] = target;
  }

  void clearTargets() {
    // Set current eventTargets to a new object, clean old targets by gc.
    _eventTargets = <int, EventTarget>{};
  }

  Element createElement(
      int id, Pointer<NativeEventTarget> nativePtr, String type, Map<String, dynamic>? props, List<String>? events) {
    assert(!existsTarget(id), 'ERROR: Can not create element with same id "$id"');

    List<String> eventList;
    if (events != null) {
      eventList = [];
      for (var eventName in events) {
        if (eventName is String) eventList.add(eventName);
      }
    }

    Element element = element_registry.createElement(id, nativePtr, type, this);
    setEventTarget(element);
    return element;
  }

  void createTextNode(int id, Pointer<NativeEventTarget> nativePtr, String data) {
    TextNode textNode = TextNode(id, nativePtr, data, this);
    setEventTarget(textNode);
  }

  void createDocumentFragment(int id, Pointer<NativeEventTarget> nativePtr) {
    DocumentFragment documentFragment = DocumentFragment(id, nativePtr, this);
    setEventTarget(documentFragment);
  }

  void createComment(int id, Pointer<NativeEventTarget> nativePtr) {
    EventTarget comment = Comment(id, nativePtr, this);
    setEventTarget(comment);
  }

  void cloneNode(int originalId, int newId) {
    EventTarget originalTarget = getEventTargetByTargetId(originalId)!;
    EventTarget newTarget = getEventTargetByTargetId(newId)!;

    // Current only element clone will process in dart.
    if (originalTarget is Element) {
      Element newElement = newTarget as Element;
      // Copy inline style.
      originalTarget.inlineStyle.forEach((key, value) {
        newElement.setInlineStyle(key, value);
      });
      // Copy element attributes.
      originalTarget.properties.forEach((key, value) {
        newElement.setProperty(key, value);
      });
    }
  }

  void removeNode(int targetId) {
    assert(existsTarget(targetId), 'targetId: $targetId');

    Node target = getEventTargetByTargetId<Node>(targetId)!;

    // Should detach renderObject.
    target.disposeRenderObject();

    target.parentNode?.removeChild(target);

    _debugDOMTreeChanged();
  }

  // TODO: https://wicg.github.io/construct-stylesheets/#using-constructed-stylesheets
  List<CSSStyleSheet> adoptedStyleSheets = [];
  List<CSSStyleSheet> styleSheets = [];

  void addStyleSheet(CSSStyleSheet sheet) {
    styleSheets.add(sheet);
    recalculateDocumentStyle();
  }

  void removeStyleSheet(CSSStyleSheet sheet) {
    styleSheets.remove(sheet);
    recalculateDocumentStyle();
  }

  void recalculateDocumentStyle() {
    // Recalculate style for all nodes sync.
    document.documentElement.recalculateNestedStyle();
  }

  void setProperty(int targetId, String key, dynamic value) {
    assert(existsTarget(targetId), 'targetId: $targetId key: $key value: $value');
    Node target = getEventTargetByTargetId<Node>(targetId)!;

    if (target is Element) {
      // Only Element has properties.
      target.setProperty(key, value);
    } else if (target is TextNode && key == 'data' || key == 'nodeValue') {
      (target as TextNode).data = value;
    } else {
      debugPrint('Only element has properties, try setting $key to Node(#$targetId).');
    }
  }

  dynamic getProperty(int targetId, String key) {
    assert(existsTarget(targetId), 'targetId: $targetId key: $key');
    Node target = getEventTargetByTargetId<Node>(targetId)!;

    if (target is Element) {
      // Only Element has properties
      return target.getProperty(key);
    } else if (target is TextNode && key == 'data' || key == 'nodeValue') {
      return (target as TextNode).data;
    } else {
      return null;
    }
  }

  void removeProperty(int targetId, String key) {
    assert(existsTarget(targetId), 'targetId: $targetId key: $key');
    Node target = getEventTargetByTargetId<Node>(targetId)!;

    if (target is Element) {
      target.removeProperty(key);
    } else if (target is TextNode && key == 'data' || key == 'nodeValue') {
      (target as TextNode).data = '';
    } else {
      debugPrint('Only element has properties, try removing $key from Node(#$targetId).');
    }
  }

  void setInlineStyle(int targetId, String key, dynamic value) {
    assert(existsTarget(targetId), 'id: $targetId key: $key value: $value');
    Node? target = getEventTargetByTargetId<Node>(targetId);
    if (target == null) return;

    if (target is Element) {
      target.setInlineStyle(key, value);
    } else {
      debugPrint('Only element has style, try setting style.$key from Node(#$targetId).');
    }
  }

  void flushPendingStyleProperties(int targetId) {
    if (!existsTarget(targetId)) return;
    Node? target = getEventTargetByTargetId<Node>(targetId);
    if (target == null) return;

    if (target is Element) {
      target.style.flushPendingProperties();
    } else {
      debugPrint('Only element has style, try flushPendingStyleProperties from Node(#$targetId).');
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
    assert(existsTarget(targetId), 'targetId: $targetId position: $position newTargetId: $newTargetId');
    assert(existsTarget(newTargetId), 'newTargetId: $newTargetId position: $position');

    Node target = getEventTargetByTargetId<Node>(targetId)!;
    Node newNode = getEventTargetByTargetId<Node>(newTargetId)!;
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
  }

  void addEvent(int targetId, String eventType) {
    if (!existsTarget(targetId)) return;
    EventTarget target = getEventTargetByTargetId<EventTarget>(targetId)!;

    if (target is Element) {
      target.addEvent(eventType);
    } else if (target is Window) {
      target.addEvent(eventType);
    } else if (target is Document) {
      target.addEvent(eventType);
    }
  }

  void removeEvent(int targetId, String eventType) {
    assert(existsTarget(targetId), 'targetId: $targetId event: $eventType');

    Element target = getEventTargetByTargetId<Element>(targetId)!;

    target.removeEvent(eventType);
  }

  RenderBox getRootRenderBox() {
    return viewport;
  }

  double getRootFontSize() {
    RenderBoxModel rootBoxModel = viewportElement.renderBoxModel!;
    return rootBoxModel.renderStyle.fontSize.computedValue;
  }

  bool showPerformanceOverlay = false;

  RenderBox buildRenderBox({bool showPerformanceOverlay = false}) {
    this.showPerformanceOverlay = showPerformanceOverlay;

    RenderBox renderBox = getRootRenderBox();

    // We need to add PerformanceOverlay of it's needed.
    if (showPerformanceOverlayOverride != null) showPerformanceOverlay = showPerformanceOverlayOverride!;

    if (showPerformanceOverlay) {
      RenderPerformanceOverlay renderPerformanceOverlay =
          RenderPerformanceOverlay(optionsMask: 15, rasterizerThreshold: 0);
      RenderConstrainedBox renderConstrainedPerformanceOverlayBox = RenderConstrainedBox(
        child: renderPerformanceOverlay,
        additionalConstraints: BoxConstraints.tight(Size(
          math.min(350.0, window.physicalSize.width),
          math.min(150.0, window.physicalSize.height),
        )),
      );
      RenderFpsOverlay renderFpsOverlayBox = RenderFpsOverlay();

      renderBox = RenderStack(
        children: [
          renderBox,
          renderConstrainedPerformanceOverlayBox,
          renderFpsOverlayBox,
        ],
        textDirection: TextDirection.ltr,
      );
    }

    return renderBox;
  }

  void attach(RenderObject parent, RenderObject? previousSibling, {bool showPerformanceOverlay = false}) {
    RenderObject root = buildRenderBox(showPerformanceOverlay: showPerformanceOverlay);

    if (parent is ContainerRenderObjectMixin) {
      parent.insert(root, after: previousSibling);
    } else if (parent is RenderObjectWithChildMixin) {
      parent.child = root;
    }
  }

  void detach() {
    RenderObject? parent = viewport.parent as RenderObject?;

    if (parent == null) return;

    // Detach renderObjects
    viewportElement.disposeRenderObject();

    // run detachCallbacks
    for (var callback in _detachCallbacks) {
      callback();
    }
    _detachCallbacks.clear();
  }

  // Hooks for DevTools.
  VoidCallback? debugDOMTreeChanged;
  void _debugDOMTreeChanged() {
    VoidCallback? f = debugDOMTreeChanged;
    if (f != null) {
      f();
    }
  }

  void dispose() {
    _teardownObserver();
    debugDOMTreeChanged = null;
  }

  @override
  void didChangeAccessibilityFeatures() { }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { }

  @override
  void didChangeLocales(List<Locale>? locale) { }

  WindowPadding _prevViewInsets = window.viewInsets;

  @override
  void didChangeMetrics() {
    double bottomInset = window.viewInsets.bottom / window.devicePixelRatio;
    if (_prevViewInsets.bottom > window.viewInsets.bottom) {
      // Hide keyboard
      viewport.bottomInset = bottomInset;
    } else {
      bool shouldScrollByToCenter = false;
      InputElement? focusInputElement = InputElement.focusInputElement;
      if (focusInputElement != null) {
        RenderBox? renderer = focusInputElement.renderer;
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
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          viewportElement.scrollBy(dy: bottomInset);
        });
      }
    }
    _prevViewInsets = window.viewInsets;
  }

  @override
  void didChangePlatformBrightness() { }

  @override
  void didChangeTextScaleFactor() { }

  @override
  void didHaveMemoryPressure() { }

  @override
  Future<bool> didPopRoute() async {
    return false;
  }

  @override
  Future<bool> didPushRoute(String route) async {
    return false;
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    return false;
  }
}
