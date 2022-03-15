/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';

class Pointer {
  Pointer(PointerEvent event) : _event = event;

  PointerEvent _event;
  PointerEvent get event => _event;

  void updateEvent(PointerEvent event) {
    _event = event;
  }

  EventTarget? _eventTarget;
  EventTarget? get eventTarget => _eventTarget;

  void updateEventTarget(EventTarget eventTarget) {
    _eventTarget = eventTarget;
  }
}

