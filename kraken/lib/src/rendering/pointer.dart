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
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) {
    return (this.localToGlobal(Offset(0,0)) & this.size).contains(this.localToGlobal(position));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    return child?.hitTest(result, position: position);
  }
}

