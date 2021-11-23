/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:flutter/rendering.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

class Document extends Node {
  final HTMLElement documentElement;

  Document(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager, this.documentElement)
      : super(NodeType.DOCUMENT_NODE, targetId, nativeEventTarget, elementManager);

  @override
  String get nodeName => '#document';

  @override
  RenderBox? get renderer => elementManager.viewport;

  addEvent(String eventType) {
    if (eventHandlers.containsKey(eventType)) return; // Only listen once.

    switch (eventType) {
      case EVENT_SCROLL:
        // Fired at the Document or element when the viewport or element is scrolled, respectively.
        return documentElement.addEventListener(eventType, dispatchEvent);
      default:
        // Events listened on the Window need to be proxied to the Document, because there is a RenderView on the Document, which can handle hitTest.
        // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/VisualViewport.cpp#L61
        documentElement.addEvent(eventType);
        break;
    }
  }
}
