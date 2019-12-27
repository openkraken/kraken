/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';

class RenderBoxModel extends RenderPointerListener {
  RenderBoxModel({
    RenderBox child,
    PointerDownEventListener onPointerDown,
    PointerMoveEventListener onPointerMove,
    PointerUpEventListener onPointerUp,
    PointerCancelEventListener onPointerCancel,
    PointerSignalEventListener onPointerSignal,
    HitTestBehavior behavior,
    this.style,
  }) : super(
    child: child,
    onPointerDown: onPointerDown,
    onPointerMove: onPointerMove,
    onPointerUp: onPointerUp,
    onPointerCancel: onPointerCancel,
    onPointerSignal: onPointerSignal,
    behavior: behavior,
  );
  Map<String, dynamic> style;
}

