

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';

mixin CSSSliverMixin on RenderStyleBase {

  Axis _sliverAxis = Axis.vertical;
  Axis get sliverAxis => _sliverAxis;
  set sliverAxis(Axis value) {
    if (_sliverAxis != value) {
      _sliverAxis = value;

      if (renderBoxModel is RenderRecyclerLayout) {
        RenderRecyclerLayout recyclerLayout = renderBoxModel as RenderRecyclerLayout;
        AxisDirection axisDirection = RenderRecyclerLayout.getAxisDirection(value);

        recyclerLayout.scrollable = KrakenScrollable(axisDirection: axisDirection);
        recyclerLayout.viewport
          ..axisDirection = axisDirection
          ..crossAxisDirection = RenderRecyclerLayout.getCrossAxisDirection(value)
          ..offset = recyclerLayout.scrollable.position!;

        recyclerLayout.markNeedsLayout();
      }
    }
  }

  void updateSliver(String value) {
    sliverAxis = resolveAxis(value);
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
