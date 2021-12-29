/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:core';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

// CSS Box Model: https://drafts.csswg.org/css-box-4/
mixin CSSBoxMixin on RenderStyle {

  final DecorationPosition decorationPosition = DecorationPosition.background;
  final ImageConfiguration imageConfiguration = ImageConfiguration.empty;

  /// What decoration to paint, should get value after layout.
  CSSBoxDecoration? get decoration {
    List<Radius>? radius = this.borderRadius;
    List<BorderSide>? borderSides = this.borderSides;

    if (backgroundColor == null &&
        backgroundImage == null &&
        borderSides == null &&
        radius == null &&
        shadows == null) {
      return null;
    }

    Border? border;
    if (borderSides != null) {
      // Side read inorder left top right bottom.
      border = Border(left: borderSides[0], top: borderSides[1], right: borderSides[2], bottom: borderSides[3]);
    }

    BorderRadius? borderRadius;
    // Flutter border radius only works when border is uniform.
    if (radius != null && (border == null || border.isUniform)) {
      borderRadius = BorderRadius.only(
        topLeft: radius[0],
        topRight: radius[1],
        bottomRight: radius[2],
        bottomLeft: radius[3],
      );
    }

    Gradient? gradient = backgroundImage?.gradient;
    if (gradient is BorderGradientMixin && border != null) {
      gradient.borderEdge = border.dimensions as EdgeInsets;
    }

    DecorationImage? decorationImage;
    ImageProvider? image = backgroundImage?.image;
    if (image!= null) {
      decorationImage = DecorationImage(
        image: image,
        repeat: backgroundRepeat,
      );
    }

    return CSSBoxDecoration(
      boxShadow: shadows,
      color: gradient != null ? null : backgroundColor, // FIXME: chrome will work with gradient and color.
      image: decorationImage,
      border: border,
      borderRadius: borderRadius,
      gradient: gradient,
    );
  }
}

class CSSBoxDecoration extends BoxDecoration {
  CSSBoxDecoration({
    this.color,
    this.image,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundBlendMode,
    this.shape = BoxShape.rectangle,
  }): super(color: color, image: image, border: border, borderRadius: borderRadius,
    gradient: gradient, backgroundBlendMode: backgroundBlendMode, shape: shape);

  @override
  final Color? color;

  @override
  final DecorationImage? image;

  @override
  final BoxBorder? border;

  @override
  final BorderRadiusGeometry? borderRadius;

  @override
  final List<KrakenBoxShadow>? boxShadow;

  @override
  final Gradient? gradient;

  @override
  final BlendMode? backgroundBlendMode;

  @override
  final BoxShape shape;

  CSSBoxDecoration clone({
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    List<KrakenBoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape? shape,
  }) {
    return CSSBoxDecoration(
      color: color ?? this.color,
      image: image ?? this.image,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      gradient: gradient ?? this.gradient,
      backgroundBlendMode: backgroundBlendMode ?? this.backgroundBlendMode,
      shape: shape ?? this.shape,
    );
  }
}

