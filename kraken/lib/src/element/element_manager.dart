/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:core';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/scheduler.dart';

Element _createElement(
    int id, String type, Map<String, dynamic> props, List<String> events) {
  switch (type) {
    case DIV:
      return DivElement(id, props, events);
    case SPAN:
      return SpanElement(id, props, events);
    case IMAGE:
      return ImageElement(id, props, events);
    case PARAGRAPH:
      return ParagraphElement(id, props, events);
    case INPUT:
      return InputElement(id, props, events);
    case CANVAS:
      return CanvasElement(id, props, events);
    case ANIMATION_PLAYER:
      return AnimationPlayerElement(id, props, events);
    case VIDEO:
      return VideoElement(id, props, events);
    case CAMERA:
      return CameraPreviewElement(id, props, events);
    case IFRAME:
      return IFrameElement(id, props, events);
    case AUDIO:
      return AudioElement(id, props, events);
    default:
      throw Exception('ERROR: unexpected element type "$type"');
  }
}

const int BODY_ID = -1;
const int WINDOW_ID = -2;

class ElementManagerActionDelegate {
  Element rootElement;

  ElementManagerActionDelegate() {
    rootElement = BodyElement(BODY_ID);
    _root = rootElement.renderObject;
    setEventTarget(rootElement);
    setEventTarget(Window());
  }

  RenderBox _root;
  RenderBox get root => _root;
  set root(RenderObject root) {
    assert(() {
      throw FlutterError('Can not set root to ElementManagerActionDelegate.');
    }());
  }

  void createElement(
      int id, String type, Map<String, dynamic> props, List events) {
    assert(
        !existsTarget(id), 'ERROR: Can not create element with same id "$id"');

    List<String> eventList;
    if (events != null) {
      eventList = [];
      for (var eventName in events) {
        if (eventName is String) eventList.add(eventName);
      }
    }

    setEventTarget(_createElement(id, type, props, eventList));
  }

  void createTextNode(int id, String data) {
    TextNode textNode = TextNode(id, data);
    setEventTarget(textNode);
  }

  void createComment(int id, String data) {
    setEventTarget(Comment(id, data));
  }

  void removeNode(int targetId) {
    assert(existsTarget(targetId), 'targetId: $targetId');

    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    target?.parentNode?.removeChild(target);
    removeTarget(targetId);
  }

  void setProperty(int targetId, String key, value) {
    assert(
        existsTarget(targetId), 'targetId: $targetId key: $key value: $value');
    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    if (target is Element) {
      // Only Element has properties
      target.setProperty(key, value);
    } else if (target is TextNode && key == 'data') {
      target.data = value;
    } else {
      debugPrint(
          'Only element has properties, try setting $key to Node(#$targetId).');
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
      debugPrint(
          'Only element has properties, try removing $key from Node(#$targetId).');
    }
  }

  void setStyle(int targetId, String key, value) {
    assert(existsTarget(targetId), 'id: $targetId key: $key value: $value');
    Node target = getEventTargetByTargetId<Node>(targetId);
    assert(target != null);

    if (target is Element) {
      target.setStyle(key, value);
    } else {
      debugPrint(
          'Only element has style, try setting style.$key from Node(#$targetId).');
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
    assert(existsTarget(targetId),
        'targetId: $targetId position: $position newTargetId: $newTargetId');

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
            target.parentNode
                .childNodes[target.parentNode.childNodes.indexOf(target) + 1],
          );
        }

        break;
    }
    RendererBinding.instance.renderView.performLayout();
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
    assert(existsTarget(targetId),
        'targetId: $targetId, method: $method, args: $args');
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
}

class ElementManager {
  static ElementManagerActionDelegate _actionDelegate;
  static ElementManager _managerSingleton = ElementManager._();
  factory ElementManager() => _managerSingleton;

  ElementManager._() {
    _actionDelegate = ElementManagerActionDelegate();
  }

  static bool showPerformanceOverlayOverride;

  RenderBox getRootRenderObject() {
    return _actionDelegate.root;
  }

  Element getRootElement() {
    return _actionDelegate.rootElement;
  }

  bool showPerformanceOverlay = false;

  void connect({bool showPerformanceOverlay}) {
    if (showPerformanceOverlay != null) {
      this.showPerformanceOverlay = showPerformanceOverlay;
    }

    RenderBox result = getRootRenderObject();

    // We need to add PerformanceOverlay of it's needed.
    if (showPerformanceOverlayOverride != null)
      showPerformanceOverlay = showPerformanceOverlayOverride;

    if (showPerformanceOverlay) {
      RenderPerformanceOverlay renderPerformanceOverlay =
          RenderPerformanceOverlay(optionsMask: 15, rasterizerThreshold: 0);
      RenderConstrainedBox renderConstrainedPerformanceOverlayBox =
          RenderConstrainedBox(
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

    RendererBinding.instance.renderView.child = result;
  }

  void disconnect() async {
    RendererBinding.instance.renderView.child = null;
    clearTargets();
    await VideoElement.disposeVideos();
    _managerSingleton = ElementManager._();
  }

  static applyAction(String action, List payload) {
    var returnValue;

    switch (action) {
      case 'createElement':
        var props, events;
        if (payload.length > 2) {
          props = payload[2];
          if (payload.length > 3) events = payload[3];
        }
        _actionDelegate.createElement(payload[0], payload[1], props, events);
        break;
      case 'createTextNode':
        _actionDelegate.createTextNode(payload[0], payload[1]);
        break;
      case 'createComment':
        _actionDelegate.createComment(payload[0], payload[1]);
        break;
      case 'insertAdjacentNode':
        _actionDelegate.insertAdjacentNode(payload[0], payload[1], payload[2]);
        break;
      case 'removeNode':
        _actionDelegate.removeNode(payload[0]);
        break;
      case 'setStyle':
        _actionDelegate.setStyle(payload[0], payload[1], payload[2]);
        break;
      case 'setProperty':
        _actionDelegate.setProperty(payload[0], payload[1], payload[2]);
        break;
      case 'getProperty':
        returnValue = _actionDelegate.getProperty(payload[0], payload[1]);
        break;
      case 'removeProperty':
        _actionDelegate.removeProperty(payload[0], payload[1]);
        break;
      case 'addEvent':
        _actionDelegate.addEvent(payload[0], payload[1]);
        break;
      case 'removeEvent':
        _actionDelegate.removeEvent(payload[0], payload[1]);
        break;
      case 'method':
        returnValue =
            _actionDelegate.method(payload[0], payload[1], payload[2]);
        break;
    }

    return returnValue;
  }
}
