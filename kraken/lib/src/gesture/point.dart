/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';

class Point {
  Point(this.event);

  PointerEvent event;

  RenderPointerListenerMixin? target;
}
