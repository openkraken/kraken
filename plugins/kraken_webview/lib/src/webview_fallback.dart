/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' hide Gradient;
import 'fallback_view.dart';

import '../platform_interface.dart';

/// Builds a fallback webview.
///
/// This is used as the default implementation for [WebViewElement.platform]. It uses
/// an [RenderParagraph] to show basic information of webview settings, only for developers.
class FallbackWebView implements WebViewPlatform {
  // Do nothing.
  void dispose() {}

  @override
  RenderBox buildRenderBox({
    CreationParams creationParams,
    WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler, onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    VoidCallback onFocus,
  }) {
    String description = _getWebViewDescriptionFromCreationParams(creationParams);
    TextStyle textStyle = TextStyle(
      color: Color(0xFF000000),
      backgroundColor: Color(0xFFFFFFFF)
    );

    return RenderFallbackViewBox(
      child: RenderParagraph(
        TextSpan(text: description, style: textStyle),
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

String _getWebViewDescriptionFromCreationParams(CreationParams creationParams) {
  assert(creationParams != null);
  return 'WebView(${creationParams.initialUrl}) userAgent: ${creationParams.userAgent}';
}
