/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

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
      // TODO: customize style
      style: const TextStyle(),
    );

    return RenderParagraph(
      text,
      textDirection: TextDirection.ltr,
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

  return '';
}
