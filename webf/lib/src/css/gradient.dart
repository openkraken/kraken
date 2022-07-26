/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui show Gradient;

import 'package:flutter/painting.dart';

// ignore: must_be_immutable
class CSSLinearGradient extends LinearGradient with BorderGradientMixin {
  /// Creates a linear gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must
  /// have the same length as [colors].
  CSSLinearGradient({
    Alignment begin = Alignment.centerLeft,
    Alignment end = Alignment.centerRight,
    double? angle,
    required List<Color> colors,
    // A list of values from 0.0 to 1.0 that denote fractions along the gradient.
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
  }) : _angle = angle,
        super(begin: begin, end: end, colors: colors, stops: stops, tileMode: tileMode, transform: transform);

  final double? _angle;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    if (borderEdge != null) {
      rect = Rect.fromLTRB(rect.left + borderEdge!.left, rect.top + borderEdge!.top, rect.right - borderEdge!.right,
          rect.bottom - borderEdge!.bottom);
    }
    double? angle;
    if (_angle != null) {
      angle = _angle;
    } else {
      Alignment point = end as Alignment;
      angle = math.atan2(point.x * rect.height, -point.y * rect.width) - math.pi * 2;
    }
    // https://drafts.csswg.org/css-images-3/#linear-gradient-syntax
    double sin = math.sin(angle!);
    double cos = math.cos(angle);

    double width = rect.width;
    double height = rect.height;
    // If width/height is null, x/y can be infinite.
    if (width == 0 || height == 0) {
      return ui.Gradient.linear(Offset.zero, Offset.zero, colors);
    }

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
      rect.top + halfHeight - y * halfHeight,
    );
    return ui.Gradient.linear(
        beginOffset, endOffset, colors, _impliedStops(), tileMode, _resolveTransform(rect, textDirection));
  }
}

// ignore: must_be_immutable
class CSSRadialGradient extends RadialGradient with BorderGradientMixin {
  /// Creates a linear gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must
  /// have the same length as [colors].
  CSSRadialGradient({
    AlignmentGeometry center = Alignment.center,
    double radius = 1.0,
    required List<Color> colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
  }) : super(center: center, radius: radius, colors: colors, stops: stops, tileMode: tileMode, transform: transform);

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    if (borderEdge != null) {
      rect = Rect.fromLTRB(rect.left + borderEdge!.left, rect.top + borderEdge!.top, rect.right - borderEdge!.right,
          rect.bottom - borderEdge!.bottom);
    }
    Offset centerOffset = center.resolve(textDirection).withinRect(rect);
    // calculate the longest distance from center to cornor
    double centerX, centerY;
    if (centerOffset.dx < rect.left) {
      centerX = rect.left;
    } else if (centerOffset.dx < rect.right) {
      centerX = centerOffset.dx;
    } else {
      centerX = rect.right;
    }

    if (centerOffset.dy < rect.top) {
      centerY = rect.top;
    } else if (centerOffset.dy < rect.bottom) {
      centerY = centerOffset.dy;
    } else {
      centerY = rect.bottom;
    }
    double width = math.max((centerX - rect.left), (rect.right - centerX));
    double height = math.max((centerY - rect.top), (rect.bottom - centerY));
    double radiusValue = radius * 2 * math.sqrt(width * width + height * height);

    return ui.Gradient.radial(
      centerOffset,
      radiusValue,
      colors,
      _impliedStops(),
      tileMode,
      _resolveTransform(rect, textDirection),
      focal == null ? null : focal!.resolve(textDirection).withinRect(rect),
      focalRadius * rect.shortestSide,
    );
  }
}

// ignore: must_be_immutable
class CSSConicGradient extends SweepGradient with BorderGradientMixin {
  /// Creates a linear gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must
  /// have the same length as [colors].
  CSSConicGradient(
      {AlignmentGeometry center = Alignment.center,
      required List<Color> colors,
      List<double>? stops,
      GradientTransform? transform})
      : super(center: center, colors: colors, stops: stops, transform: transform);

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    if (borderEdge != null) {
      rect = Rect.fromLTRB(rect.left - borderEdge!.left, rect.top - borderEdge!.top, rect.right - borderEdge!.right,
          rect.bottom - borderEdge!.bottom);
    }
    return super.createShader(rect, textDirection: textDirection);
  }
}

mixin BorderGradientMixin on Gradient {
  /// BorderSize to deflate.
  EdgeInsets? _borderEdge;
  EdgeInsets? get borderEdge => _borderEdge;
  set borderEdge(EdgeInsets? newValue) {
    _borderEdge = newValue;
  }

  List<double>? _impliedStops() {
    if (stops != null) return stops;
    assert(colors.length >= 2, 'colors list must have at least two colors');
    final double separation = 1.0 / (colors.length - 1);
    return List<double>.generate(
      colors.length,
      (int index) => index * separation,
      growable: false,
    );
  }

  Float64List? _resolveTransform(Rect bounds, TextDirection? textDirection) {
    return transform?.transform(bounds, textDirection: textDirection)?.storage;
  }
}
