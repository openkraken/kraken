/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';

/// RenderLeaderLayer of [TextFormControlElement] used for toolbar overlay to float with.
class RenderTextControlLeaderLayer extends RenderLeaderLayer {
  RenderTextControlLeaderLayer({
    required LayerLink link,
    RenderTextControl? child,
    required this.scrollable,
    this.renderEditable,
    this.isMultiline = false,
  }) : super(link: link, child: child);

  RenderEditable? renderEditable;

  KrakenScrollable scrollable;

  bool isMultiline;

  void _pointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      scrollable.handlePointerDown(event);
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

    RenderIntrinsic renderIntrinsic = parent as RenderIntrinsic;
    RenderStyle renderStyle = renderIntrinsic.renderStyle;

    double intrinsicInputHeight = renderEditable!.preferredLineHeight
      + renderStyle.paddingTop.computedValue + renderStyle.paddingBottom.computedValue
      + renderStyle.effectiveBorderTopWidth.computedValue + renderStyle.effectiveBorderBottomWidth.computedValue;

    // Editable area should align to the center vertically for input element which
    // does not support multiline editing.
    double dy;
    if (renderStyle.height.isNotAuto) {
      dy = (renderStyle.height.computedValue - intrinsicInputHeight) / 2;
    } else if (renderStyle.lineHeight.type != CSSLengthType.NORMAL &&
      renderStyle.lineHeight.computedValue > intrinsicInputHeight) {
      dy = (renderStyle.lineHeight.computedValue - intrinsicInputHeight) /2;
    } else {
      dy = 0;
    }
    return Offset(0, dy);
  }

  // Note paint override can not be done in RenderTextControl cause input toolbar
  // paints relative to the perferred height of textPainter.
  @override
  void paint(PaintingContext context, Offset offset) {
    final Offset transformedOffset = offset.translate(_offset!.dx, _offset!.dy);
    super.paint(context, transformedOffset);
  }
}

/// RenderBox of [TextFormControlElement].
class RenderTextControl extends RenderProxyBox {
  RenderTextControl({
    required RenderEditable child,
  }) : super(child);

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      Size childSize = child!.size;
      double width = constraints.maxWidth != double.infinity ?
      constraints.maxWidth : childSize.width;

      RenderTextControlLeaderLayer renderLeaderLayer = parent as RenderTextControlLeaderLayer;
      RenderIntrinsic renderIntrinsic = renderLeaderLayer.parent as RenderIntrinsic;
      RenderStyle renderStyle = renderIntrinsic.renderStyle;

      double height;
      // Height priority: height > max(line-height, child height) > child height
      if (constraints.maxHeight != double.infinity) {
        height = constraints.maxHeight;
      } else  {
        height = math.max(renderStyle.lineHeight.computedValue, childSize.height);
      }

      size = Size(width, height);
    } else {
      size = computeSizeForNoChild(constraints);
    }
  }
}

