/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:core';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:ffi';

import 'package:flutter/scheduler.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/launcher.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/rendering.dart';

const String UNKNOWN = 'UNKNOWN';

Element _createElement(int id, Pointer nativePtr, String type, Map<String, dynamic> props,
    List<EventType> events, ElementManager elementManager) {
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
      element = CameraPreviewElement(id, nativePtr.cast<NativeCameraElement>(), elementManager);
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
      element = Element(id, nativePtr, elementManager, tagName: UNKNOWN);
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
    for (EventType eventName in events) {
      element.addEvent(eventName);
    }
  }

  return element;
}

const int BODY_ID = -1;
const int WINDOW_ID = -2;

class ElementManager {
  // Call from JS Bridge before JS side eventTarget object been Garbage collected.
  static void disposeEventTarget(int contextId, int id) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget eventTarget = controller.view.getEventTargetById(id);
    eventTarget.dispose();
  }

  Element _rootElement;
  Map<int, EventTarget> _eventTargets = <int, EventTarget>{};
  bool showPerformanceOverlayOverride;
  KrakenController controller;

  final double viewportWidth;
  final double viewportHeight;

  final List<VoidCallback> _detachCallbacks = [];

  ElementManager(this.viewportWidth, this.viewportHeight, {int contextId, this.controller, this.showPerformanceOverlayOverride}) {
    print('body nativePtr: ${bodyNativePtrMap[contextId]}');
    _rootElement =
        BodyElement(viewportWidth, viewportHeight, BODY_ID, bodyNativePtrMap[contextId], this)
          ..attachBody();

    RenderBoxModel root = _rootElement.renderBoxModel;
    root.controller = controller;
    _root = root;
    setEventTarget(_rootElement);
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

  void initWindow(Pointer<NativeWindow> nativePtr) {
    Window window = Window(WINDOW_ID, nativePtr, this);
    setEventTarget(window);
  }

  Element createElement(
      int id, Pointer nativePtr, String type, Map<String, dynamic> props, List<EventType> events) {
    assert(!existsTarget(id), 'ERROR: Can not create element with same id "$id"');

    List<EventType> eventList;
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

    target.parentNode?.removeChild(target);
    // Remove node reference to ElementManager
    target.elementManager = null;
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

    print('target node: $target, newNode: $newNode');
    switch (position) {
      case 'beforebegin':
        target?.parentNode?.insertBefore(newNode, target);
        break;
      case 'afterbegin':
        target.insertBefore(newNode, target.firstChild);
        break;
      case 'beforeend':
        print('apendChild');
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
  }

  void addEvent(int targetId, int eventTypeIndex) {
    EventType eventType = EventType.values[eventTypeIndex];
    assert(existsTarget(targetId), 'targetId: $targetId event: $eventType');
    if (eventType == EventType.none) return;

    EventTarget target = getEventTargetByTargetId<EventTarget>(targetId);
    assert(target != null);

    target.addEvent(eventType);
  }

  void removeEvent(int targetId, EventType eventType) {
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
}
