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
import 'package:flutter/rendering.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/rendering.dart';

const String UNKNOWN = 'UNKNOWN';

Element _createElement(
    int id, String type, Map<String, dynamic> props, List<String> events, ElementManager elementManager) {
  Element element;
  switch (type) {
    case DIV:
      element = DivElement(id, elementManager);
      break;
    case SPAN:
      element = SpanElement(id, elementManager);
      break;
    case ANCHOR:
      element = AnchorElement(id, elementManager);
      break;
    case STRONG:
      element = StrongElement(id, elementManager);
      break;
    case IMAGE:
      element = ImageElement(id, elementManager);
      break;
    case PARAGRAPH:
      element = ParagraphElement(id, elementManager);
      break;
    case INPUT:
      element = InputElement(id, elementManager);
      break;
    case PRE:
      element = PreElement(id, elementManager);
      break;
    case CANVAS:
      element = CanvasElement(id, elementManager);
      break;
    case ANIMATION_PLAYER:
      element = AnimationPlayerElement(id, elementManager);
      break;
    case VIDEO:
      element = VideoElement(id, elementManager);
      break;
    case CAMERA_PREVIEW:
      element = CameraPreviewElement(id, elementManager);
      break;
    case IFRAME:
      element = IFrameElement(id, elementManager);
      break;
    case AUDIO:
      element = AudioElement(id, elementManager);
      break;
    case OBJECT:
      element = ObjectElement(id, elementManager);
      break;
    default:
      element = Element(id, elementManager, tagName: UNKNOWN);
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

class ElementManager implements WidgetsBindingObserver, ElementsBindingObserver  {
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
      {this.viewport, this.controller, this.showPerformanceOverlayOverride}) {
    _rootElement = BodyElement(viewportWidth, viewportHeight, targetId: BODY_ID, elementManager: this)
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
    setEventTarget(Window(this));
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

  void removeTarget(Node target) {
    assert(target.targetId != null);
    target.childNodes.forEach(removeTarget);
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

  void createElement(int id, String type, Map<String, dynamic> props, List events) {
    assert(!existsTarget(id), 'ERROR: Can not create element with same id "$id"');

    List<String> eventList;
    if (events != null) {
      eventList = [];
      for (var eventName in events) {
        if (eventName is String) eventList.add(eventName);
      }
    }

    EventTarget target = _createElement(id, type, props, eventList, this);
    setEventTarget(target);
  }

  void createTextNode(int id, String data) {
    TextNode textNode = TextNode(id, data, this);
    setEventTarget(textNode);
  }

  void createComment(int id, String data) {
    EventTarget comment = Comment(targetId: id, data: data, elementManager: this);
    setEventTarget(comment);
  }

  void removeNode(int targetId) {
    assert(existsTarget(targetId), 'targetId: $targetId');

    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    target.parentNode?.removeChild(target);
    // Remove node reference to ElementManager
    target.elementManager = null;

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

  void addEvent(int targetId, String eventName) {
    assert(existsTarget(targetId), 'targetId: $targetId event: $eventName');

    EventTarget target = getEventTargetByTargetId<EventTarget>(targetId);
    assert(target != null);

    target.addEvent(eventName);
  }

  void removeEvent(int targetId, String eventName) {
    assert(existsTarget(targetId), 'targetId: $targetId event: $eventName');

    Element target = getEventTargetByTargetId<Element>(targetId);
    assert(target != null);

    target.removeEvent(eventName);
  }

  method(int targetId, String method, args) {
    assert(existsTarget(targetId), 'targetId: $targetId, method: $method, args: $args');
    Element target = getEventTargetByTargetId<Element>(targetId);
    List _args;
    try {
      _args = (args as List).cast();
    } catch (e, stack) {
      if (!PRODUCTION) {
        print('Method parse error: $e\n$stack');
      }
      _args = [];
    }
    assert(target != null);
    assert(target.method != null);
    return target.method(method, _args);
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

  RenderBox buildRenderBox({ bool showPerformanceOverlay  }) {
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

    if (parent is ContainerRenderObjectMixin) {
      parent.remove(root);
    } else if (parent is RenderObjectWithChildMixin) {
      parent.child = null;
    }

    clearTargets();
    for (var callback in _detachCallbacks) {
       callback();
    }
    _detachCallbacks.clear();
    _rootElement = null;
  }

  dynamic applyAction(String action, List payload) {
    dynamic returnValue;

    switch (action) {
      case 'createElement':
        var props, events;
        if (payload.length > 2) {
          props = payload[2];
          if (payload.length > 3) events = payload[3];
        }
        createElement(payload[0], payload[1], props, events);
        break;
      case 'createTextNode':
        createTextNode(payload[0], payload[1]);
        break;
      case 'createComment':
        createComment(payload[0], payload[1]);
        break;
      case 'insertAdjacentNode':
        insertAdjacentNode(payload[0], payload[1], payload[2]);
        break;
      case 'removeNode':
        removeNode(payload[0]);
        break;
      case 'setStyle':
        setStyle(payload[0], payload[1], payload[2]);
        break;
      case 'setProperty':
        setProperty(payload[0], payload[1], payload[2]);
        break;
      case 'getProperty':
        returnValue = getProperty(payload[0], payload[1]);
        break;
      case 'removeProperty':
        removeProperty(payload[0], payload[1]);
        break;
      case 'addEvent':
        addEvent(payload[0], payload[1]);
        break;
      case 'removeEvent':
        removeEvent(payload[0], payload[1]);
        break;
      case 'method':
        returnValue = method(payload[0], payload[1], payload[2]);
        break;
    }

    return returnValue;
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
    controller.dispose();
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
