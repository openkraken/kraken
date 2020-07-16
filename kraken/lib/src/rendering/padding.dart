import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class KrakenRenderPadding extends RenderPadding {
  KrakenRenderPadding({padding, child}) : super(padding: padding, child: child);

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    child?.hitTest(result, position: position);
    if (this.size.contains(this.globalToLocal(position))) {
      result.add(BoxHitTestEntry(this, position));
    }
    return true;
  }
}
