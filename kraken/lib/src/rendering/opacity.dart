import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class KrakenRenderOpacity extends RenderOpacity {
  KrakenRenderOpacity({
    double opacity = 1.0,
    bool alwaysIncludeSemantics = false,
    RenderBox child,
  }) : super(opacity: opacity, alwaysIncludeSemantics: alwaysIncludeSemantics,child: child);

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}

