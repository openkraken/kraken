import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui show Gradient, lerpDouble;

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

class CustomLinearGradient extends LinearGradient with CustomGradientMixin {

  /// Creates a linear gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must
  /// have the same length as [colors].
  CustomLinearGradient({
    Alignment begin = Alignment.centerLeft,
    Alignment end = Alignment.centerRight,
    double angle,
    @required List<Color> colors,
    List<double> stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform transform,
  }) : _angle = angle,
      super(begin: begin, end: end, colors: colors, stops: stops, tileMode: tileMode, transform: transform);

  double _angle;

  @override
  Shader createShader(Rect rect, {TextDirection textDirection}) {
    if (borderEdge != null) {
      rect = Rect.fromLTRB(rect.left + borderEdge.left, rect.top + borderEdge.top,
        rect.right - borderEdge.right, rect.bottom - borderEdge.bottom);
    }
    double angle;
    if (_angle != null) {
      angle = _angle;
    } else {
      Alignment point = end as Alignment;
      angle =  math.atan2(point.x * rect.height, -point.y * rect.width) - math.pi *2;
    }
    // https://drafts.csswg.org/css-images-3/#linear-gradient-syntax
    double sin = math.sin(angle);
    double cos = math.cos(angle);

    double width = rect.width;
    double height = rect.height;
    double length = (sin * width).abs() + (cos * height).abs();
    double x = sin * length / width;
    double y = cos * length / height;
    final double halfWidth = rect.width / 2.0;
    final double halfHeight = rect.height / 2.0;
    Offset beginOffset = Offset(
      rect.left + halfWidth + -x * halfWidth,
      rect.top + halfHeight + y * halfHeight,
    );
    Offset endOffset = Offset(
      rect.left + halfWidth + x * halfWidth,
      rect.top + halfHeight + -y * halfHeight,
    );
    return ui.Gradient.linear(
      beginOffset, endOffset, colors, _impliedStops(), tileMode,
      _resolveTransform(rect, textDirection)
    );
  }

  List<double> _impliedStops() {
    if (stops != null)
      return stops;
    assert(colors.length >= 2, 'colors list must have at least two colors');
    final double separation = 1.0 / (colors.length - 1);
    return List<double>.generate(
      colors.length,
        (int index) => index * separation,
      growable: false,
    );
  }

  Float64List _resolveTransform(Rect bounds, TextDirection textDirection) {
    return transform?.transform(bounds, textDirection: textDirection)?.storage;
  }
}

class CustomRadialGradient extends RadialGradient with CustomGradientMixin {

  /// Creates a linear gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must
  /// have the same length as [colors].
  CustomRadialGradient({
    AlignmentGeometry center = Alignment.center,
    double radius,
    @required List<Color> colors,
    List<double> stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform transform,
  }) : super(center: center, radius: radius, colors: colors, stops: stops, tileMode: tileMode, transform: transform);

  @override
  Shader createShader(Rect rect, {TextDirection textDirection}) {
    if (borderEdge != null) {
      rect = Rect.fromLTRB(rect.left - borderEdge.left, rect.top - borderEdge.top, rect.right - borderEdge.right, rect.bottom - borderEdge.bottom);
    }
    return super.createShader(rect, textDirection: textDirection);
  }
}

class CustomSweepGradient extends SweepGradient with CustomGradientMixin {

  /// Creates a linear gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must
  /// have the same length as [colors].
  CustomSweepGradient({
    AlignmentGeometry center = Alignment.center,
    @required List<Color> colors,
    List<double> stops,
    GradientTransform transform
  }) : super(center: center, colors: colors, stops: stops, transform: transform);

  @override
  Shader createShader(Rect rect, {TextDirection textDirection}) {
    if (borderEdge != null) {
      rect = Rect.fromLTRB(rect.left - borderEdge.left, rect.top - borderEdge.top, rect.right - borderEdge.right, rect.bottom - borderEdge.bottom);
    }
    return super.createShader(rect, textDirection: textDirection);
  }
}

mixin CustomGradientMixin {

  /// BorderSize to deflate.
  EdgeInsets _borderEdge;
  EdgeInsets get borderEdge => _borderEdge;
  set borderEdge(EdgeInsets newValue) {
    _borderEdge = newValue;
  }
}
