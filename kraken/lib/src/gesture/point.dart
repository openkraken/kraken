/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';

class Point {
  Point(PointerEvent event) : _event = event;

  PointerEvent _event;
  PointerEvent get event => _event;

  void updateEvent(PointerEvent event) {
    _event = event;
  }

  RenderPointerListenerMixin? target;
}
