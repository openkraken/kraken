/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// An interface that [Scrollable] widgets implement in order to use
/// [ScrollPosition].
///
/// See also:
///
///  * [ScrollableState], which is the most common implementation of this
///    interface.
///  * [ScrollPosition], which uses this interface to communicate with the
///    scrollable widget.
abstract class ScrollContext {
  /// A [TickerProvider] to use when animating the scroll position.
  TickerProvider get vsync;

  /// The direction in which the widget scrolls.
  AxisDirection get axisDirection;

  /// Whether the user can drag the widget, for example to initiate a scroll.
  void setCanDrag(bool value);

  /// Set the [SemanticsAction]s that should be expose to the semantics tree.
  void setSemanticsActions(Set<SemanticsAction?>? actions);
}
