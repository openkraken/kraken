/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';

import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';

void initBridge() {
  initJSEngine();
  registerDartFunctionIntoCpp();
}

@pragma('vm:entry-point')
void createElement(String type, int id, String props, String events) {
  ElementManager().applyAction(
    ElementAction.createElement,
    null,
    node: PayloadNode.fromParams(type, id, props, events),
  );
}

@pragma('vm:entry-point')
void createTextNode(String type, int id, String props, String events) {
  ElementManager().applyAction(
    ElementAction.createTextNode,
    null,
    node: PayloadNode.fromParams(type, id, props, events),
  );
}

@pragma('vm:entry-point')
void setStyle(int targetId, String key, String value) {
  ElementManager().applyAction(ElementAction.setStyle, [targetId, key, value]);
}

@pragma('vm:entry-point')
void removeNode(int targetId) {
  ElementManager().applyAction(ElementAction.removeNode, [targetId]);
}

@pragma('vm:entry-point')
void insertAdjacentNode(int targetId, String position, int nodeId) {
  ElementManager().applyAction(
      ElementAction.insertAdjacentNode, [targetId, position, nodeId]);
}

@pragma('vm:entry-point')
void setProperty(int targetId, String key, String value) {
  ElementManager()
      .applyAction(ElementAction.setProperty, [targetId, key, value]);
}

@pragma('vm:entry-point')
void removeProperty(int targetId, String key) {
  ElementManager().applyAction(ElementAction.removeProperty, [targetId, key]);
}

@pragma('vm:entry-point')
void method(int targetId, String method, String args) {
  ElementManager()
      .applyAction(ElementAction.method, [targetId, method, jsonEncode(args)]);
}
