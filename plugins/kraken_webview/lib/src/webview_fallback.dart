/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' hide Gradient;

import '../platform_interface.dart';


const Color _white = Color(0xFFFFFFFF);
const Color _black = Color(0xBF000000);
const Color _yellow = Color(0xBFFFFF00);
/// Builds a fallback webview.
///
/// This is used as the default implementation for [WebViewElement.platform]. It uses
/// an [RenderParagraph] to show basic information of webview settings, only for developers.
class FallbackWebView implements WebViewPlatform {
  @override
  RenderBox buildRenderBox({
    CreationParams creationParams,
    WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler, onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers
  }) {
    String description = _getWebViewDescriptionFromCreationParams(creationParams);
    TextSpan text = TextSpan(
      text: description,
      style: const TextStyle(
        backgroundColor: _white,
        color: _black,
      ),
    );

    return RenderFallbackViewBox(
      child: RenderParagraph(
        text,
        textDirection: TextDirection.ltr,
      ),
    );
  }

  @override
  Future<bool> clearCookies() async {
    // Do nothing.
    return true;
  }
}

class RenderFallbackViewBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderFallbackViewBox({
    RenderBox child
  }) : assert(child != null) {
    this.child = child;
  }

  static final Paint _linePaint = Paint()
    ..shader = Gradient.linear(
      const Offset(0.0, 0.0),
      const Offset(10.0, 10.0),
      <Color>[_black, _yellow, _yellow, _black],
      <double>[0.25, 0.25, 0.75, 0.75],
      TileMode.repeated,
    );

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height), _linePaint);
    if (child != null) {
      // Add some offset to show borders.
      child.paint(context, offset + Offset(5.0, 5.0));
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    if (child != null) {
      child.layout(constraints);
    }
  }
}

String _getWebViewDescriptionFromCreationParams(CreationParams creationParams) {
  assert(creationParams != null);
  return 'WebView(${creationParams.initialUrl}) userAgent: ${creationParams.userAgent}';
}
