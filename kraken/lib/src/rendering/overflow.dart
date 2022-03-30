/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/gesture.dart';

mixin RenderOverflowMixin on RenderBoxModelBase {
  ScrollListener? scrollListener;
  void Function(PointerEvent)? scrollablePointerListener;

  void disposeScrollable() {
    scrollListener = null;
    scrollablePointerListener = null;
    _scrollOffsetX = null;
    _scrollOffsetY = null;
    // Dispose clip layer.
    _clipRRectLayer.layer = null;
    _clipRectLayer.layer = null;
  }

  bool get clipX {
    RenderBoxModel renderBoxModel = this as RenderBoxModel;

    // Recycler layout not need repaintBoundary and scroll/pointer listeners,
    // ignoring overflowX or overflowY sets, which handle it self.
    if (renderBoxModel is RenderSliverListLayout) {
      return false;
    }

    List<Radius>? borderRadius = renderBoxModel.renderStyle.borderRadius;

    // The content of replaced elements is always trimmed to the content edge curve.
    // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
    if( borderRadius != null
      && this is RenderReplaced
      && renderStyle.intrinsicRatio != null
    ) {
      return true;
    }

    // Overflow value other than 'visible' always need to clip content.
    // https://www.w3.org/TR/css-overflow-3/#overflow-properties
    CSSOverflowType effectiveOverflowX = renderStyle.effectiveOverflowX;
    if (effectiveOverflowX != CSSOverflowType.visible) {
      Size scrollableSize = renderBoxModel.scrollableSize;
      Size scrollableViewportSize = renderBoxModel.scrollableViewportSize;
      // Border-radius always to clip inner content when overflow is not visible.
      if (scrollableSize.width > scrollableViewportSize.width
        || borderRadius != null
      ) {
        return true;
      }
    }

    return false;
  }

  bool get clipY {
    RenderBoxModel renderBoxModel = this as RenderBoxModel;

    // Recycler layout not need repaintBoundary and scroll/pointer listeners,
    // ignoring overflowX or overflowY sets, which handle it self.
    if (renderBoxModel is RenderSliverListLayout) {
      return false;
    }

    List<Radius>? borderRadius = renderStyle.borderRadius;

    // The content of replaced elements is always trimmed to the content edge curve.
    // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
    if( borderRadius != null
      && this is RenderReplaced
      && renderStyle.intrinsicRatio != null
    ) {
      return true;
    }

    // Overflow value other than 'visible' always need to clip content.
    // https://www.w3.org/TR/css-overflow-3/#overflow-properties
    CSSOverflowType effectiveOverflowY = renderStyle.effectiveOverflowY;
    if (effectiveOverflowY != CSSOverflowType.visible) {
      Size scrollableSize = renderBoxModel.scrollableSize;
      Size scrollableViewportSize = renderBoxModel.scrollableViewportSize;
      // Border-radius always to clip inner content when overflow is not visible.
      if (scrollableSize.height > scrollableViewportSize.height
        || borderRadius != null
      ) {
        return true;
      }
    }
    return false;
  }

  Size? _scrollableSize;
  Size? _viewportSize;

  ViewportOffset? get scrollOffsetX => _scrollOffsetX;
  ViewportOffset? _scrollOffsetX;
  set scrollOffsetX(ViewportOffset? value) {
    if (value == _scrollOffsetX) return;
    _scrollOffsetX?.removeListener(_scrollXListener);
    _scrollOffsetX = value;
    _scrollOffsetX?.addListener(_scrollXListener);
    markNeedsLayout();
  }

  ViewportOffset? get scrollOffsetY => _scrollOffsetY;
  ViewportOffset? _scrollOffsetY;
  set scrollOffsetY(ViewportOffset? value) {
    if (value == _scrollOffsetY) return;
    _scrollOffsetY?.removeListener(_scrollYListener);
    _scrollOffsetY = value;
    _scrollOffsetY?.addListener(_scrollYListener);
    markNeedsLayout();
  }

  void _scrollXListener() {
    assert(scrollListener != null);
    scrollListener!(scrollOffsetX!.pixels, AxisDirection.right);
    markNeedsPaint();
  }

  void _scrollYListener() {
    assert(scrollListener != null);
    scrollListener!(scrollOffsetY!.pixels, AxisDirection.down);
    markNeedsPaint();
  }

  void _setUpScrollX() {
    _scrollOffsetX!.applyViewportDimension(_viewportSize!.width);
    _scrollOffsetX!.applyContentDimensions(0.0, math.max(0.0, _scrollableSize!.width - _viewportSize!.width));
  }

  void _setUpScrollY() {
    _scrollOffsetY!.applyViewportDimension(_viewportSize!.height);
    _scrollOffsetY!.applyContentDimensions(0.0, math.max(0.0, _scrollableSize!.height - _viewportSize!.height));
  }

  void setUpOverflowScroller(Size scrollableSize, Size viewportSize) {
    // Recycler layout not need repaintBoundary and scroll/pointer listeners,
    // ignoring overflowX or overflowY sets, which handle it self.
    if (this is RenderSliverListLayout) {
      return;
    }

    _scrollableSize = scrollableSize;
    _viewportSize = viewportSize;
    if (_scrollOffsetX != null) {
      _setUpScrollX();
    }

    if (_scrollOffsetY != null) {
      _setUpScrollY();
    }
  }

  double get _paintOffsetX {
    if (_scrollOffsetX == null) return 0.0;
    return -_scrollOffsetX!.pixels;
  }
  double get _paintOffsetY {
    if (_scrollOffsetY == null) return 0.0;
    return -_scrollOffsetY!.pixels;
  }

  double get scrollTop {
    if (_scrollOffsetY == null) return 0.0;
    return _scrollOffsetY!.pixels;
  }

  double get scrollLeft {
    if (_scrollOffsetX == null) return 0.0;
    return _scrollOffsetX!.pixels;
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset, Size childSize) {
    return paintOffset < Offset.zero || !(Offset.zero & size).contains((paintOffset & childSize).bottomRight);
  }

  final LayerHandle<ClipRRectLayer> _clipRRectLayer = LayerHandle<ClipRRectLayer>();
  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  void paintOverflow(
    PaintingContext context,
    Offset offset,
    EdgeInsets borderEdge,
    CSSBoxDecoration? decoration,
    PaintingContextCallback callback
  ) {
    if (clipX == false && clipY == false) return callback(context, offset);

    final double paintOffsetX = _paintOffsetX;
    final double paintOffsetY = _paintOffsetY;
    final Offset paintOffset = Offset(paintOffsetX, paintOffsetY);
    // Overflow should not cover border.
    Rect clipRect = Offset(borderEdge.left, borderEdge.top) & Size(
      size.width - borderEdge.right - borderEdge.left,
      size.height - borderEdge.bottom - borderEdge.top,
    );
    if (_shouldClipAtPaintOffset(paintOffset, size)) {
      // ignore: prefer_function_declarations_over_variables
      PaintingContextCallback painter = (PaintingContext context, Offset offset) {
        callback(context, offset + paintOffset);
      };

      // If current or its descendants has a compositing layer caused by styles
      // (eg. transform, opacity, overflow...), then it needs to create a new layer
      // or else the clip in the older layer will not work.
      bool _needsCompositing = needsCompositing;

      if (decoration != null && decoration.hasBorderRadius) {
        BorderRadius radius = decoration.borderRadius!;
        Rect rect = Offset.zero & size;
        RRect borderRRect = radius.toRRect(rect);
        // A borderRadius can only be given for a uniform Border in Flutter.
        // https://github.com/flutter/flutter/issues/12583
        double? borderTop = renderStyle.borderTopWidth?.computedValue;
        // The content of overflow is trimmed to the padding edge curve.
        // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
        RRect clipRRect = borderTop != null
          ? borderRRect.deflate(borderTop)
          : borderRRect;

        // The content of replaced elements is trimmed to the content edge curve.
        if (this is RenderReplaced) {
          // @TODO: Currently only support clip uniform padding for replaced element.
          double paddingTop = renderStyle.paddingTop.computedValue;
          clipRRect = clipRRect.deflate(paddingTop);
        }
        _clipRRectLayer.layer = context.pushClipRRect(_needsCompositing, offset, clipRect, clipRRect, painter, oldLayer: _clipRRectLayer.layer);
      } else {
        _clipRectLayer.layer = context.pushClipRect(_needsCompositing, offset, clipRect, painter, oldLayer: _clipRectLayer.layer);
      }
    } else {
      _clipRectLayer.layer = null;
      _clipRRectLayer.layer = null;
      callback(context, offset);
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    double? result;
    final BoxParentData? childParentData = parentData as BoxParentData?;
    double? candidate = getDistanceToActualBaseline(baseline);
    if (candidate != null) {
      candidate += childParentData!.offset.dy;
      if (result != null)
        result = math.min(result, candidate);
      else
        result = candidate;
    }
    return result;
  }

  void applyOverflowPaintTransform(RenderBox child, Matrix4 transform) {
    final Offset paintOffset = Offset(_paintOffsetX, _paintOffsetY);
    transform.translate(paintOffset.dx, paintOffset.dy);
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) {
    final Offset paintOffset = Offset(_paintOffsetX, _paintOffsetY);
    if (_shouldClipAtPaintOffset(paintOffset, size)) return Offset.zero & size;
    return null;
  }

  void debugOverflowProperties(DiagnosticPropertiesBuilder properties) {
    if (_scrollableSize != null) properties.add(DiagnosticsProperty('scrollableSize', _scrollableSize));
    if (_viewportSize != null) properties.add(DiagnosticsProperty('viewportSize', _viewportSize));
    properties.add(DiagnosticsProperty('clipX', clipX));
    properties.add(DiagnosticsProperty('clipY', clipY));
  }
}

