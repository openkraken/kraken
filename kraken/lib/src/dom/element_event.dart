/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

enum AppearEventType {
  none,
  appear,
  disappear
}

mixin ElementEventMixin on ElementBase {
  AppearEventType prevAppearState = AppearEventType.none;

  void addEventResponder(RenderPointerListenerMixin renderBox) {
    renderBox.onClick = handleMouseEvent;
    renderBox.onDoubleClick = dispatchEvent;
    renderBox.onSwipe = dispatchEvent;
    renderBox.onPan = dispatchEvent;
    renderBox.onScale = dispatchEvent;
    renderBox.onLongPress = dispatchEvent;
    renderBox.getEventHandlers = getEventHandlers;
    renderBox.getEventTarget = getEventTarget;
    renderBox.dispatchEvent = dispatchEvent;
  }

  void removeEventResponder(RenderPointerListenerMixin renderBox) {
    renderBox.onClick = null;
    renderBox.onDoubleClick = null;
    renderBox.onSwipe = null;
    renderBox.onPan = null;
    renderBox.onScale = null;
    renderBox.onLongPress = null;
    renderBox.getEventTarget = null;
    renderBox.dispatchEvent = null;
    renderBox.getEventHandlers = null;
  }

  EventTarget getEventTarget() {
    return this;
  }

  void handleMouseEvent(String eventType, TapUpDetails details) {
    RenderBoxModel? root = ownerDocument.documentElement!.renderBoxModel;
    if (root == null) {
      return;
    }

    // When Kraken wraps the Flutter Widget, Kraken need to calculate the global coordinates relative to self.
    Offset globalOffset = root.globalToLocal(Offset(details.globalPosition.dx, details.globalPosition.dy));
    dispatchEvent(MouseEvent(eventType,
      MouseEventInit(
        bubbles: true,
        cancelable: true,
        clientX: globalOffset.dx,
        clientY: globalOffset.dy,
        offsetX: details.localPosition.dx,
        offsetY: details.localPosition.dy,
      )
    ));
  }

  void handleAppear() {
    if (prevAppearState == AppearEventType.appear) return;
    prevAppearState = AppearEventType.appear;

    dispatchEvent(AppearEvent());
  }

  void handleDisappear() {
    if (prevAppearState == AppearEventType.disappear) return;
    prevAppearState = AppearEventType.disappear;
    dispatchEvent(DisappearEvent());
  }

  void handleIntersectionChange(IntersectionObserverEntry entry) {
    dispatchEvent(IntersectionChangeEvent(entry.intersectionRatio));
    if (entry.intersectionRatio > 0) {
      handleAppear();
    } else {
      handleDisappear();
    }
  }
}
