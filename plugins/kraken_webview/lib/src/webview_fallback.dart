/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' hide Gradient;
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

import '../platform_interface.dart';

/// Builds a fallback webview.
///
/// This is used as the default implementation for [WebViewElement.platform]. It uses
/// an [RenderParagraph] to show basic information of webview settings, only for developers.
class FallbackWebView with TextStyleMixin implements WebViewPlatform {
  @override
  RenderBox buildRenderBox({
    CreationParams creationParams,
    WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler, onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers
  }) {
    String description = _getWebViewDescriptionFromCreationParams(creationParams);
    TextStyle style = getTextStyle(Style(null)).copyWith(backgroundColor: WebColor.white);

    return RenderFallbackViewBox(
      child: RenderParagraph(
        TextSpan(text: description, style: style),
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
