/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:core';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/style.dart';

Element _createElement(int id, String type, Map<String, dynamic> props, List<String> events) {
  switch (type) {
    case DIV:
      return DivElement(id, props, events);
    case SPAN:
      return SpanElement(id, props, events);
    case IMAGE:
      return ImgElement(id, props, events);
    case PARAGRAPH:
      return ParagraphElement(id, props, events);
    case INPUT:
      return InputElement(id, props, events);
    case CANVAS:
      return CanvasElement(id, props, events);
    case ANIMATION:
      return AnimationElement(id, props, events);
    case VIDEO:
      {
        VideoElement.setDefaultPropsStyle(props);
        return VideoElement(id, props, events);
      }
    default:
      throw Exception('ERROR: unexpected element type "$type"');
  }
}

Map<int, dynamic> nodeMap = {};

class ElementManagerActionDelegate {
  final int BODY_ID = -1;
  Element rootElement;

  ElementManagerActionDelegate() {
    rootElement = BodyElement(BODY_ID);
    _root = RenderDecoratedBox(decoration: BoxDecoration(color: WebColor.white), child: rootElement.renderObject);
    nodeMap[BODY_ID] = rootElement;
  }

  RenderBox _root;
  RenderBox get root => _root;
  set root(RenderObject root) {
    assert(() {
      throw FlutterError('Can not set root to ElementManagerActionDelegate.');
    }());
  }

  void createElement(int id, String type, Map<String, dynamic> props, List<dynamic> events) {
    if (nodeMap.containsKey(id)) {
      throw Exception('ERROR: can not create element with same id "$id"');
    }

    List<String> eventList = [];
    if (events != null) {
      for (var eventName in events) {
        if (eventName is String) eventList.add(eventName);
      }
    }

    nodeMap[id] = _createElement(id, type, props, eventList);
  }

  void createTextNode(int id, String data) {
    TextNode textNode = TextNode(id, data);
    nodeMap[id] = textNode;
  }

  void createComment(int id, String data) {
    nodeMap[id] = Comment(id, data);
  }

  void removeNode(int targetId) {
    assert(nodeMap.containsKey(targetId));

    Node target = nodeMap[targetId];
    assert(target != null);

    target?.parentNode?.removeChild(target);
    nodeMap.remove(targetId);
  }

  void setProperty(int targetId, String key, dynamic value) {
    assert(nodeMap.containsKey(targetId));
    Node target = nodeMap[targetId];
    assert(target != null);

    target.setProperty(key, value);
  }

  void setStyle(int targetId, String key, String value) {
    assert(nodeMap.containsKey(targetId));
    Element target = nodeMap[targetId];
    assert(target != null);

    target.setProperty(STYLE_PATH_PREFIX + '.' + key, value);
  }

  void removeProperty(int targetId, String key) {
    assert(nodeMap.containsKey(targetId));
    Node target = nodeMap[targetId];
    assert(target != null);

    target.removeProperty(key);
  }

  /// <!-- beforebegin -->
  /// <p>
  ///   <!-- afterbegin -->
  ///   foo
  ///   <!-- beforeend -->
  /// </p>
  /// <!-- afterend -->
  void insertAdjacentNode(int targetId, String position, int nodeId) {
    assert(nodeMap.containsKey(targetId));
    assert(nodeMap.containsKey(nodeId));

    Node target = nodeMap[targetId];
    Node newNode = nodeMap[nodeId];

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
    RendererBinding.instance.renderView.performLayout();
  }

  void addEvent(int targetId, String eventName) {
    assert(nodeMap.containsKey(targetId));

    Element target = nodeMap[targetId];
    assert(target != null);

    target.addEvent(eventName);
  }

  void removeEvent(int targetId, String eventName) {
    assert(nodeMap.containsKey(targetId));

    Element target = nodeMap[targetId];
    assert(target != null);

    target.removeEvent(eventName);
  }

  dynamic method(int targetId, String method, dynamic args) {
    assert(nodeMap.containsKey(targetId));

    Element target = nodeMap[targetId];
    assert(target != null);
    dynamic res = target.method(method, args);
    return res;
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

    RendererBinding.instance.renderView.child = result;
  }

  void disconnect() {
    RendererBinding.instance.renderView.child = null;
    nodeMap.clear();
    _managerSingleton = ElementManager._();
  }

  static dynamic applyAction(String action, List payload) {
    var returnValue;

    switch (action) {
      case 'createElement':
        _actionDelegate.createElement(payload[0], payload[1], payload[2], payload[3]);
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
        returnValue = _actionDelegate.method(payload[0], payload[1], payload[2]);
        break;
    }

    return returnValue;
  }
}
