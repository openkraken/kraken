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
        backgroundColor: WebColor.white,
        color: WebColor.black,
        // Use a fixed font family fallback to avoid
        // rendering difference in multi platforms.
        fontFamilyFallback: KRAKEN_DEFAULT_FONT_FAMILY_FALLBACK,
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

String _getWebViewDescriptionFromCreationParams(CreationParams creationParams) {
  assert(creationParams != null);
  return 'WebView(${creationParams.initialUrl}) userAgent: ${creationParams.userAgent}';
}
