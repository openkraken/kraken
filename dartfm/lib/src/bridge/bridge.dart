/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:ui' show window;

import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
import 'package:requests/requests.dart';
import 'fetch.dart' show Fetch;
import 'timer.dart';
import 'message.dart';

const String BATCH_UPDATE = 'batchUpdate';
KrakenTimer timer = KrakenTimer();

ElementAction getAction(String action) {
  switch (action) {
    case 'createElement':
      return ElementAction.createElement;
    case 'createTextNode':
      return ElementAction.createTextNode;
    case 'insertAdjacentNode':
      return ElementAction.insertAdjacentNode;
    case 'removeNode':
      return ElementAction.removeNode;
    case 'setStyle':
      return ElementAction.setStyle;
    case 'setProperty':
      return ElementAction.setProperty;
    case 'removeProperty':
      return ElementAction.removeProperty;
    case 'addEvent':
      return ElementAction.addEvent;
    case 'removeEvent':
      return ElementAction.removeEvent;
    case 'method':
      return ElementAction.method;
    default:
      return null;
  }
}

String krakenJsToDart(String args) {
  dynamic directives = jsonDecode(args);
  if (directives[0] == BATCH_UPDATE) {
    List<dynamic> children = directives[1];
    List<String> result = [];
    for (dynamic child in children) {
      result.add(handleJSToDart(child as List));
    }
    return result.join(',');
  } else {
    return handleJSToDart(directives);
  }
}

String handleJSToDart(List directive) {
  ElementAction action = getAction(directive[0]);
  List payload = directive[1];
  var result = ElementManager().applyAction(action, payload);

  if (result == null) {
    return '';
  }

  switch (result.runtimeType) {
    case String:
      {
        return result;
      }
    case Map:
    case List:
      return jsonEncode(result);
    default:
      return result.toString();
  }
}

void initBridge() {
  initJSEngine();
  registerDartFunctionIntoCpp();
}

void reloadApp() async {
  bool prevShowPerformanceOverlay = elementManager?.showPerformanceOverlay ?? false;
  appLoading = true;
  unmountApp();
  await reloadJSContext();
  appLoading = false;
  connect(prevShowPerformanceOverlay);
}

int setTimeout(int callbackId, int timeout) {
  return timer.setTimeout(callbackId, timeout);
}

int setInterval(int callbackId, int timeout) {
  return timer.setInterval(callbackId, timeout);
}

void clearTimeout(int timerId) {
  return timer.clearTimeout(timerId);
}

void clearInterval = clearTimeout;

int requestAnimationFrame(int callbackId) {
  return timer.requestAnimationFrame(callbackId);
}

void cancelAnimationFrame(int timerId) {
  timer.cancelAnimationFrame(timerId);
}

@pragma('vm:entry-point')
double getScreenAvailHeight() {
  return window.physicalSize.height;
}

@pragma('vm:entry-point')
double getScreenAvailWidth() {
  return window.physicalSize.width;
}

@pragma('vm:entry-point')
double getScreenHeight() {
  return window.physicalSize.height;
}

@pragma('vm:entry-point')
double getScreenWidth() {
  return window.physicalSize.width;
}

@pragma('vm:entry-point')
void fetch(int callbackId, String url, String json) {
  StringBuffer data = StringBuffer('[$callbackId]');
  Fetch.fetch(url, json).then((Response response) {
    response.raiseForStatus();
    data.write(
        Message.buildMessage('statusCode', response.statusCode.toString()));
    data.write(Message.buildMessage('body', response.content()));
    CPPMessage(FETCH_MESSAGE, data.toString()).send();
  }).catchError((e) {
    if (e is HTTPException) {
      data.write(
          Message.buildMessage('statusCode', e.response.statusCode.toString()));
      data.write(Message.buildMessage('error', e.message));
    } else {
      data.write(Message.buildMessage('error', e.toString()));
    }

    CPPMessage(FETCH_MESSAGE, data.toString()).send();
  });
}

void initScreenMetricsChangedCallback() {
  var frameworkCallback = window.onMetricsChanged;

  sendWindowSize() {
    double devicePixelRatio = window.devicePixelRatio;
    double width = window.physicalSize.width / devicePixelRatio;
    double height = window.physicalSize.height / devicePixelRatio;
    StringBuffer buffer = StringBuffer();
    buffer.write(Message.buildMessage('width', width.toString()));
    buffer.write(Message.buildMessage('height', height.toString()));
    buffer.write(Message.buildMessage('availWidth', width.toString()));
    buffer.write(Message.buildMessage('availHeight', height.toString()));

    CPPMessage(SCREEN_METRICS, buffer.toString()).send();
    CPPMessage(WINDOW_INIT_DEVICE_PIXEL_RATIO, devicePixelRatio.toString())
        .send();
  }

  sendWindowSize();

  window.onMetricsChanged = () {
    // call framework callback first
    frameworkCallback();

    sendWindowSize();
  };
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
  ElementManager().applyAction(ElementAction.insertAdjacentNode, [targetId, position, nodeId]);
}

@pragma('vm:entry-point')
void setProperty(int targetId, String key, String value) {
  ElementManager().applyAction(ElementAction.setProperty, [targetId, key, value]);
}

@pragma('vm:entry-point')
void removeProperty(int targetId, String key) {
  ElementManager().applyAction(ElementAction.removeProperty, [targetId, key]);
}

@pragma('vm:entry-point')
void method(int targetId, String method, String args) {
  ElementManager().applyAction(ElementAction.method, [targetId, method, jsonEncode(args)]);
}
