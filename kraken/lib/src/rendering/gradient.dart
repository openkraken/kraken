import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:meta/meta.dart';

class RenderGradient extends RenderDecoratedBox {
  int _targetId;

  RenderGradient({
    @required int targetId,
    @required Decoration decoration,
    DecorationPosition position = DecorationPosition.background,
    ImageConfiguration configuration = ImageConfiguration.empty,
    RenderBox child,
  })  : this._targetId = targetId,
        super(
            decoration: decoration,
            position: position,
            configuration: configuration,
            child: child);

  @override
  void performLayout() {
    super.performLayout();
    _applyGradient();
  }

  void _applyGradient() {
    Decoration box = decoration;
    if (box is BoxDecoration) {
      Gradient gradient = box.gradient;
      if (gradient is LinearGradient) {
        Element el = getEventTargetByTargetId<Element>(_targetId);
        if (el != null) {
          double angle = el.linearAngle;
          if (angle != null) {
            double sin = math.sin(angle);
            double cos = math.cos(angle);

            double length =
                (sin * size.width).abs() + (cos * size.height).abs();
            double x = sin * length / size.width;
            double y = cos * length / size.height;

            LinearGradient linearGradient = LinearGradient(
                begin: Alignment(-x, y),
                end: Alignment(x, -y),
                colors: gradient.colors,
                stops: gradient.stops,
                tileMode: gradient.tileMode);
            decoration = BoxDecoration(
                gradient: linearGradient,
                border: box.border,
                borderRadius: box.borderRadius,
                color: box.color,
                boxShadow: box.boxShadow);
          }
        }
      }
    }
  }
}
