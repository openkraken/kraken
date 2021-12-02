/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSSliverMixin on RenderStyle {

  @override
  Axis get sliverDirection => _sliverDirection;
  Axis _sliverDirection = Axis.vertical;
  set sliverDirection(Axis value) {
    if (_sliverDirection == value) return;
    _sliverDirection = value;
    renderBoxModel?.markNeedsLayout();
  }

  static Axis resolveAxis(String sliverDirection) {
    switch (sliverDirection) {
      case ROW:
        return Axis.horizontal;

      case COLUMN:
      default:
        return Axis.vertical;
    }
  }
}
