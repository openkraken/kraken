import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class KrakenRenderConstrainedBox extends RenderConstrainedBox {

  KrakenRenderConstrainedBox({
    RenderBox child,
    @required BoxConstraints additionalConstraints,
  }) : super(child: child, additionalConstraints: additionalConstraints);

  @override
  void layout(Constraints constraints, { bool parentUsesSize = false }) {
    Constraints additional = additionalConstraints;
    Constraints result = constraints;
    if (constraints is BoxConstraints && additional is BoxConstraints) {
      result = constraints.enforce(additional);
    }
    super.layout(result, parentUsesSize: parentUsesSize);
  }

  @override
  void performLayout() {
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
    } else {
      size = constraints.constrain(Size.zero);
    }
  }
}
