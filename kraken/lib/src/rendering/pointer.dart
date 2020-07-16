import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class KrakenRenderPointerListener extends RenderPointerListener {
  KrakenRenderPointerListener({
    onPointerDown,
    onPointerMove,
    onPointerUp,
    onPointerCancel,
    onPointerSignal,
    HitTestBehavior behavior = HitTestBehavior.deferToChild,
    RenderBox child,
  }) : super(onPointerDown: onPointerDown, onPointerMove: onPointerMove,onPointerUp: onPointerUp,onPointerCancel: onPointerCancel,onPointerSignal: onPointerSignal, behavior: behavior, child: child);

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    child?.hitTest(result, position: position);
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

