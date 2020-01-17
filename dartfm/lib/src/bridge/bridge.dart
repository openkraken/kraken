/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:ui' show window;

import 'package:kraken/element.dart';
import 'package:requests/requests.dart';
import 'fetch.dart' show Fetch;
import 'timer.dart';
import 'message.dart';

KrakenTimer timer = KrakenTimer();

@pragma('vm:entry-point')
String krakenJsToDart(String args) {
  dynamic list = jsonDecode(args);
  String action = list[0];
  List<dynamic> payload = list[1];
  dynamic result = ElementManager().applyAction(action, payload);

  if (result == null) {
    return '';
  }

  switch(result.runtimeType) {
    case String: {
      return result;
    }
    case Map:
    case List:
      return jsonEncode(result);
    default:
      return result.toString();
  }
}

@pragma('vm:entry-point')
int setTimeout(int callbackId, int timeout) {
  return timer.setTimeout(callbackId, timeout);
}

@pragma('vm:entry-point')
int setInterval(int callbackId, int timeout) {
  return timer.setInterval(callbackId, timeout);
}

@pragma('vm:entry-point')
void clearTimeout(int timerId) {
  return timer.clearTimeout(timerId);
}

@pragma('vm:entry-point')
void clearInterval(int timerId) {
  // Use same logical to clear innterval.
  return timer.clearTimeout(timerId);
}

@pragma('vm:entry-point')
int requestAnimationFrame(int callbackId) {
  return timer.requestAnimationFrame(callbackId);
}

@pragma('vm:entry-point')
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
    buffer.write(
      Message.buildMessage('width', width.toString()));
    buffer.write(
      Message.buildMessage('height', height.toString()));
    buffer.write(Message.buildMessage('availWidth', width.toString()));
    buffer.write(Message.buildMessage('availHeight', height.toString()));

    CPPMessage(SCREEN_METRICS, buffer.toString()).send();
    CPPMessage(WINDOW_INIT_DEVICE_PIXEL_RATIO, devicePixelRatio.toString()).send();
  }

  sendWindowSize();

  window.onMetricsChanged = () {
    // call framework callback first
    frameworkCallback();

    sendWindowSize();
  };
}
