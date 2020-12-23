/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:core';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding, WidgetsBindingObserver, RouteInformation;
import 'dart:ffi';

import 'package:kraken/bridge.dart';
import 'package:kraken/launcher.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/rendering.dart';

const String UNKNOWN = 'UNKNOWN';

Element _createElement(int id, Pointer nativePtr, String type, Map<String, dynamic> props,
    List<String> events, ElementManager elementManager) {
  Element element;
  switch (type) {
    case BODY:
      break;
    case DIV:
      element = DivElement(id, nativePtr.cast<NativeElement>(), elementManager);
      break;
    case SPAN:
      element = SpanElement(id, nativePtr.cast<NativeElement>(), elementManager);
      break;
    case ANCHOR:
      element = AnchorElement(id, nativePtr.cast<NativeAnchorElement>(), elementManager);
      break;
    case STRONG:
      element = StrongElement(id, nativePtr.cast<NativeElement>(), elementManager);
      break;
    case IMAGE:
      element = ImageElement(id, nativePtr.cast<NativeImgElement>(), elementManager);
      break;
    case PARAGRAPH:
      element = ParagraphElement(id, nativePtr.cast<NativeElement>(), elementManager);
      break;
    case INPUT:
      element = InputElement(id, nativePtr.cast<NativeInputElement>(), elementManager);
      break;
    case PRE:
      element = PreElement(id, nativePtr.cast<NativeElement>(), elementManager);
      break;
    case CANVAS:
      element = CanvasElement(id, nativePtr.cast<NativeCanvasElement>(), elementManager);
      break;
    case ANIMATION_PLAYER:
      element = AnimationPlayerElement(id, nativePtr.cast<NativeAnimationElement>(), elementManager);
      break;
    case VIDEO:
      element = VideoElement(id, nativePtr.cast<NativeVideoElement>(), elementManager);
      break;
    case CAMERA_PREVIEW:
      element = CameraPreviewElement(id, nativePtr.cast<NativeElement>(), elementManager);
      break;
    case IFRAME:
      element = IFrameElement(id, nativePtr.cast<NativeIframeElement>(), elementManager);
      break;
    case AUDIO:
      element = AudioElement(id, nativePtr.cast<NativeAudioElement>(), elementManager);
      break;
    case OBJECT:
      element = ObjectElement(id, nativePtr.cast<NativeObjectElement>(), elementManager);
      break;
    default:
      element = Element(id, nativePtr.cast<NativeElement>(), elementManager, tagName: UNKNOWN);
      print('ERROR: unexpected element type "$type"');
  }

  // Add element properties.
  if (props != null && props.length > 0) {
    props.forEach((String key, value) {
      element.setProperty(key, value);
    });
  }

  // Add element event listener
  if (events != null && events.length > 0) {
    for (String eventName in events) {
      element.addEvent(eventName);
    }
  }

  return element;
}

const int BODY_ID = -1;
const int WINDOW_ID = -2;
const int DOCUMENT_ID = -3;

class ElementManager implements WidgetsBindingObserver, ElementsBindingObserver  {
  // Call from JS Bridge before JS side eventTarget object been Garbage collected.
  static void disposeEventTarget(int contextId, int id) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget eventTarget = controller.view.getEventTargetById(id);
    if (eventTarget == null) return;
    eventTarget.dispose();
  }

  static Map<int, Pointer<NativeElement>> bodyNativePtrMap = Map();
  static Map<int, Pointer<NativeWindow>> windowNativePtrMap = Map();

  static double FOCUS_VIEWINSET_BOTTOM_OVERALL = 32;

  RenderViewportBox viewport;
  Element _rootElement;
  Map<int, EventTarget> _eventTargets = <int, EventTarget>{};
  bool showPerformanceOverlayOverride;
  KrakenController controller;

  final double viewportWidth;
  final double viewportHeight;

  final List<VoidCallback> _detachCallbacks = [];

  ElementManager(this.viewportWidth, this.viewportHeight,
      {int contextId, this.viewport, this.controller, this.showPerformanceOverlayOverride}) {
    _rootElement = BodyElement(viewportWidth, viewportHeight, BODY_ID, bodyNativePtrMap[contextId], this)
      ..attachBody();

    RenderBoxModel rootRenderBoxModel = _rootElement.renderBoxModel;
    if (viewport != null) {
      viewport.controller = controller;
      viewport.child = rootRenderBoxModel;
      _root = viewport;
    } else {
      rootRenderBoxModel.controller = controller;
      _root = rootRenderBoxModel;
    }

    _setupObserver();

    setEventTarget(_rootElement);

    Window window = Window(WINDOW_ID, windowNativePtrMap[contextId], this);
    setEventTarget(window);
  }

  void _setupObserver() {
    if (ElementsBinding.instance != null) {
      ElementsBinding.instance.addObserver(this);
    } else if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  void _teardownObserver() {
    if (ElementsBinding.instance != null) {
      ElementsBinding.instance.removeObserver(this);
    } else if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  T getEventTargetByTargetId<T>(int targetId) {
    assert(targetId != null);
    EventTarget target = _eventTargets[targetId];
    if (target is T)
      return target as T;
    else
      return null;
  }

  bool existsTarget(int id) {
    return _eventTargets.containsKey(id);
  }

  void removeTarget(EventTarget target) {
    assert(target.targetId != null);
    assert(_eventTargets.containsKey(target.targetId));
    _eventTargets.remove(target.targetId);
  }

  void setDetachCallback(VoidCallback callback) {
    _detachCallbacks.add(callback);
  }

  void setEventTarget(EventTarget target) {
    assert(target != null);

    _eventTargets[target.targetId] = target;
  }

  void clearTargets() {
    // Set current eventTargets to a new object, clean old targets by gc.
    _eventTargets = <int, EventTarget>{};
  }

  Element createElement(
      int id, Pointer nativePtr, String type, Map<String, dynamic> props, List<String> events) {
    assert(!existsTarget(id), 'ERROR: Can not create element with same id "$id"');

    List<String> eventList;
    if (events != null) {
      eventList = [];
      for (var eventName in events) {
        if (eventName is String) eventList.add(eventName);
      }
    }

    Element element = _createElement(id, nativePtr, type, props, eventList, this);
    setEventTarget(element);
    return element;
  }

  void createTextNode(int id, Pointer<NativeTextNode> nativePtr, String data) {
    TextNode textNode = TextNode(id, nativePtr, data, this);
    setEventTarget(textNode);
  }

  void createComment(int id, Pointer<NativeCommentNode> nativePtr, String data) {
    EventTarget comment = Comment(targetId: id, nativeCommentNodePtr: nativePtr, data: data, elementManager: this);
    setEventTarget(comment);
  }

  void removeNode(int targetId) {
    assert(existsTarget(targetId), 'targetId: $targetId');

    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    // Should detach renderObject.
    target.detach();

    target.parentNode?.removeChild(target);

    _debugDOMTreeChanged();
  }

  void setProperty(int targetId, String key, dynamic value) {
    assert(existsTarget(targetId), 'targetId: $targetId key: $key value: $value');
    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    if (target is Element) {
      // Only Element has properties
      target.setProperty(key, value);
    } else if (target is TextNode && key == 'data') {
      target.data = value;
    } else {
      debugPrint('Only element has properties, try setting $key to Node(#$targetId).');
    }
  }

  dynamic getProperty(int targetId, String key) {
    assert(existsTarget(targetId), 'targetId: $targetId key: $key');
    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    if (target is Element) {
      // Only Element has properties
      return target.getProperty(key);
    }
    return null;
  }

  void removeProperty(int targetId, String key) {
    assert(existsTarget(targetId), 'targetId: $targetId key: $key');
    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    if (target is Element) {
      target.removeProperty(key);
    } else {
      debugPrint('Only element has properties, try removing $key from Node(#$targetId).');
    }
  }

  void setStyle(int targetId, String key, dynamic value) {
    assert(existsTarget(targetId), 'id: $targetId key: $key value: $value');
    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    if (target is Element) {
      target.setStyle(key, value);
    } else {
      debugPrint('Only element has style, try setting style.$key from Node(#$targetId).');
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
    assert(existsTarget(newTargetId), 'newtargetId: $newTargetId position: $position');

    Node target = getEventTargetByTargetId<Node>(targetId);
    Node newNode = getEventTargetByTargetId<Node>(newTargetId);

    switch (position) {
      case 'beforebegin':
        target?.parentNode?.insertBefore(newNode, target);
        break;
      case 'afterbegin':
        target.insertBefore(newNode, target.firstChild);
        break;
      case 'beforeend':
        target.appendChild(newNode);
        break;
      case 'afterend':
        if (target.parentNode.lastChild == target) {
          target.parentNode.appendChild(newNode);
        } else {
          target.parentNode.insertBefore(
            newNode,
            target.parentNode.childNodes[target.parentNode.childNodes.indexOf(target) + 1],
          );
        }

        break;
    }

    _debugDOMTreeChanged();
  }

  void addEvent(int targetId, String eventType) {
    // TODO: support bind event listener on document.
    if (targetId == DOCUMENT_ID) return;

    assert(existsTarget(targetId), 'targetId: $targetId event: $eventType');
    EventTarget target = getEventTargetByTargetId<EventTarget>(targetId);
    assert(target != null);

    target.addEvent(eventType);
  }

  void removeEvent(int targetId, String eventType) {
    assert(existsTarget(targetId), 'targetId: $targetId event: $eventType');

    Element target = getEventTargetByTargetId<Element>(targetId);
    assert(target != null);

    target.removeEvent(eventType);
  }

  RenderObject _root;

  RenderObject get root => _root;

  set root(RenderObject root) {
    assert(() {
      throw FlutterError('Can not set root to ElementManagerActionDelegate.');
    }());
  }

  RenderObject getRootRenderObject() {
    return root;
  }

  Element getRootElement() {
    return _rootElement;
  }

  bool showPerformanceOverlay = false;

  RenderBox buildRenderBox({bool showPerformanceOverlay}) {
    if (showPerformanceOverlay != null) {
      this.showPerformanceOverlay = showPerformanceOverlay;
    }

    RenderBox result = getRootRenderObject();

    // We need to add PerformanceOverlay of it's needed.
    if (showPerformanceOverlayOverride != null) showPerformanceOverlay = showPerformanceOverlayOverride;

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

      result = RenderStack(
        children: [
          result,
          renderConstrainedPerformanceOverlayBox,
          renderFpsOverlayBox,
        ],
        textDirection: TextDirection.ltr,
      );
    }

    return result;
  }

  void attach(RenderObject parent, RenderObject previousSibling, {bool showPerformanceOverlay}) {
    RenderObject root = buildRenderBox(showPerformanceOverlay: showPerformanceOverlay);

    if (parent is ContainerRenderObjectMixin) {
      parent.insert(root, after: previousSibling);
    } else if (parent is RenderObjectWithChildMixin) {
      parent.child = root;
    }
  }

  void detach() {
    RenderObject parent = root.parent;

    if (parent == null) return;

    // Detach renderObjects
    _rootElement.detach();

    // run detachCallbacks
    for (var callback in _detachCallbacks) {
      callback();
    }
    _detachCallbacks.clear();

    _rootElement = null;
  }

  // Hooks for DevTools.
  VoidCallback debugDOMTreeChanged;
  void _debugDOMTreeChanged() {
    if (debugDOMTreeChanged != null) {
      debugDOMTreeChanged();
    }
  }

  void dispose() {
    _teardownObserver();
    debugDOMTreeChanged = null;
    controller = null;
  }

  @override
  void didChangeAccessibilityFeatures() { }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { }

  @override
  void didChangeLocales(List<Locale> locale) { }

  WindowPadding _prevViewInsets = window.viewInsets;

  @override
  void didChangeMetrics() {
    if (viewport != null) {
      double bottomInset = window.viewInsets.bottom / window.devicePixelRatio;
      if (_prevViewInsets.bottom > window.viewInsets.bottom) {
        // Hide keyboard
        viewport.bottomInset = bottomInset;
      } else {
        bool shouldScrollByToCenter = false;
        if (InputElement.focusInputElement != null) {
          RenderBox renderer = InputElement.focusInputElement.renderer;
          if (renderer.hasSize) {
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
            _rootElement.scrollBy(dy: bottomInset);
          });
        }
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
