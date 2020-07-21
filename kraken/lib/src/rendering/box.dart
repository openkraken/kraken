import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class KrakenRenderConstrainedBox extends RenderConstrainedBox {
  KrakenRenderConstrainedBox({
    RenderBox child,
    @required BoxConstraints additionalConstraints,
  }) : super(child: child, additionalConstraints: additionalConstraints);

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
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

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Cannot hit test a render box that has never been laid out.'),
            describeForError('The hitTest() method was called on this RenderBox'),
            ErrorDescription(
                "Unfortunately, this object's geometry is not known at this time, "
                    'probably because it has never been laid out. '
                    'This means it cannot be accurately hit-tested.'
            ),
            ErrorHint(
                'If you are trying '
                    'to perform a hit test during the layout phase itself, make sure '
                    "you only hit test nodes that have completed layout (e.g. the node's "
                    'children, after their layout() method has been called).'
            ),
          ]);
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot hit test a render box with no size.'),
          describeForError('The hitTest() method was called on this RenderBox'),
          ErrorDescription(
              'Although this node is not marked as needing layout, '
                  'its size is not set.'
          ),
          ErrorHint(
              'A RenderBox object must have an '
                  'explicit size before it can be hit-tested. Make sure '
                  'that the RenderBox in question sets its size during layout.'
          ),
        ]);
      }
      return true;
    }());
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
