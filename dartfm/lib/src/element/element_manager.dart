/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/style.dart';

enum ElementAction {
  createElement,
  createTextNode,
  insertAdjacentNode,
  removeNode,
  setStyle,
  setProperty,
  removeProperty,
  addEvent,
  removeEvent,
  method
}

abstract class ElementManagerActionDelegate {
  RenderObject root;
  Element rootElement;

  void createElement(PayloadNode node);

  void createTextNode(PayloadNode node);

  void removeNode(int targetId);

  void setProperty(int targetId, String key, dynamic value);

  void removeProperty(int targetId, String key);

  void setStyle(int targetId, String key, String value);

  void insertAdjacentNode(int targetId, String position, int nodeId);

  void addEvent(int targetId, String eventName);

  void removeEvent(int targetId, String eventName);

  dynamic method(int targetId, String method, dynamic args);
}

Map<int, dynamic> nodeMap = {};

class W3CElementManagerActionDelegate implements ElementManagerActionDelegate {
  final int BODY_ID = -1;
  @override
  Element rootElement;

  W3CElementManagerActionDelegate() {
    rootElement = BodyElement(BODY_ID);
    _root = RenderDecoratedBox(
        decoration: BoxDecoration(color: WebColor.white),
        child: rootElement.renderObject);
    nodeMap[BODY_ID] = rootElement;
  }

  RenderBox _root;
  RenderBox get root => _root;

  void createElement(PayloadNode node) {
    assert(node != null);
    if (nodeMap.containsKey(node.id)) {
      throw Exception('ERROR: can not create element with same id: $node.id');
    }

    Node el;

    switch (node.type) {
      case 'COMMENT':
        el = Comment(node.id, node.props);
        break;
      default:
        el = createW3CElement(node);
        break;
    }

    nodeMap[node.id] = el;
  }

  void createTextNode(PayloadNode node) {
    TextNode textNode = TextNode(node.id, node.props, node.data);
    nodeMap[node.id] = textNode;
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
            target.parentNode
                .childNodes[target.parentNode.childNodes.indexOf(target) + 1],
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

  @override
  set root(RenderObject _root) {
    assert(() {
      throw FlutterError(
          'Can not set root to W3CElementManagerActionDelegate.');
    }());
  }

  @override
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
    _actionDelegate = W3CElementManagerActionDelegate();
  }

  static bool showPerformanceOverlayOverride;

  RenderBox getRootRenderObject() {
    return _actionDelegate.root;
  }

  Element getRootElement() {
    return _actionDelegate.rootElement;
  }

  bool showPerformanceOverlay = false;

  void connect({ bool showPerformanceOverlay }) {
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

  void disconnect() {
    RendererBinding.instance.renderView.child = null;
    nodeMap.clear();
    _managerSingleton = ElementManager._();
  }

  dynamic applyAction(ElementAction action, List payload, { PayloadNode node }) {
    var returnValue;

    switch (action) {
      case ElementAction.createElement:
        if (node == null) node = PayloadNode.fromJson(payload[0]);
        _actionDelegate.createElement(node);
        break;
      case ElementAction.createTextNode:
        if (node == null) node = PayloadNode.fromJson(payload[0]);
        _actionDelegate.createTextNode(node);
        break;
      case ElementAction.insertAdjacentNode:
        _actionDelegate.insertAdjacentNode(payload[0], payload[1], payload[2]);
        break;
      case ElementAction.removeNode:
        _actionDelegate.removeNode(payload[0]);
        break;
      case ElementAction.setStyle:
        _actionDelegate.setStyle(payload[0], payload[1], payload[2]);
        break;
      case ElementAction.setProperty:
        _actionDelegate.setProperty(payload[0], payload[1], payload[2]);
        break;
      case ElementAction.removeProperty:
        _actionDelegate.removeProperty(payload[0], payload[1]);
        break;
      case ElementAction.addEvent:
        _actionDelegate.addEvent(payload[0], payload[1]);
        break;
      case ElementAction.removeEvent:
        _actionDelegate.removeEvent(payload[0], payload[1]);
        break;
      case ElementAction.method:
        returnValue = _actionDelegate.method(payload[0], payload[1], payload[2]);
        break;
    }

    return returnValue;
  }
}

class PayloadNode {
  int id;
  String type;
  Map<String, dynamic> props = {};
  List<String> events = [];
  String data;

  PayloadNode.fromJson(Map<String, dynamic> json) {
    List<dynamic> events = json['events'];
    id = json['id'];
    type = json['type'];

    if (json['props'] != null) {
      props = json['props'];
    }

    if (events != null) {
      for (var eventName in events) {
        if (eventName is String) this.events.add(eventName);
      }
    }
    data = json['data'];
  }

  PayloadNode.fromParams(String type, int id, String propsJson, String eventsJson) {
    this.type = type;
    this.id = id;

    if (propsJson != null && propsJson.isNotEmpty) {
      props = jsonDecode(propsJson);
    }

    if (eventsJson != null && eventsJson.isNotEmpty) {
      var events = jsonDecode(eventsJson);
      for (var eventName in events) {
        if (eventName is String) this.events.add(eventName);
      }
    }
  }

  String toString() {
    return 'PayloadNode(id: $id, type: $type, props: $props, events: $events, data: $data)';
  }
}
