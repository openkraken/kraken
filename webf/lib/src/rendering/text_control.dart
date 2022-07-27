/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart';

/// RenderLeaderLayer of [TextFormControlElement] used for toolbar overlay
/// which includes [Cut], [Copy], [Paste], [Select All] shortcuts to float with.
class RenderTextControlLeaderLayer extends RenderLeaderLayer {
  RenderTextControlLeaderLayer({
    required LayerLink link,
    RenderEditable? child,
    required this.scrollable,
    this.isMultiline = false,
  }) : super(link: link, child: child);

  WebFScrollable scrollable;

  bool isMultiline;

  void _pointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      scrollable.handlePointerDown(event);
    } else if (event is PointerSignalEvent) {
      scrollable.handlePinterSignal(event);
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    _pointerListener(event);
  }

  Offset? get _offset {
    // Editable area should align to the top vertically for textarea element which
    // supports multiline editing.
    if (isMultiline) {
      return Offset(0, 0);
    }

    RenderReplaced renderReplaced = parent as RenderReplaced;
    RenderStyle renderStyle = renderReplaced.renderStyle;

    double intrinsicHeight = (child as RenderEditable).preferredLineHeight +
        renderStyle.paddingTop.computedValue +
        renderStyle.paddingBottom.computedValue +
        renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue;

    // Editable area should align to the center vertically for text control element which
    // does not support multiline editing.
    double dy;
    if (renderStyle.height.isNotAuto) {
      dy = (renderStyle.height.computedValue - intrinsicHeight) / 2;
    } else if (renderStyle.lineHeight.type != CSSLengthType.NORMAL &&
        renderStyle.lineHeight.computedValue > intrinsicHeight) {
      dy = (renderStyle.lineHeight.computedValue - intrinsicHeight) / 2;
    } else {
      dy = 0;
    }
    return Offset(0, dy);
  }

  @override
  void performLayout() {
    super.performLayout();

    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      Size childSize = child!.size;

      RenderReplaced renderReplaced = parent as RenderReplaced;
      RenderStyle renderStyle = renderReplaced.renderStyle;

      double width;
      if (constraints.maxWidth != double.infinity) {
        width = constraints.maxWidth;
      } else {
        width = childSize.width;
      }

      double height;
      // Height priority: height > max(line-height, child height) > child height
      if (constraints.maxHeight != double.infinity) {
        height = constraints.maxHeight;
      } else {
        height = math.max(renderStyle.lineHeight.computedValue, childSize.height);
      }

      size = Size(width, height);
    } else {
      size = computeSizeForNoChild(constraints);
    }
  }

  // Note paint override can not be done in RenderTextControl cause text control toolbar
  // paints relative to the perferred height of textPainter.
  @override
  void paint(PaintingContext context, Offset offset) {
    final Offset transformedOffset = offset.translate(_offset!.dx, _offset!.dy);
    super.paint(context, transformedOffset);
  }
}
