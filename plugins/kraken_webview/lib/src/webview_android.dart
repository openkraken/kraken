// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import '../platform_interface.dart';
import 'webview_method_channel.dart';

/// Builds an Android webview.
///
/// This is used as the default implementation for [WebViewElement.platform] on Android. It uses
/// an [AndroidView] to embed the webview in the widget hierarchy, and uses a method channel to
/// communicate with the platform code.
class AndroidWebView implements WebViewPlatform {
  AndroidViewController _controller;
  int _id;

  void dispose() {
    _controller?.dispose();
  }

  @override
  RenderAndroidView buildRenderBox({
    CreationParams creationParams,
    @required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
    WebViewPlatformCreatedCallback onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    VoidCallback onFocus,
  }) {
    assert(webViewPlatformCallbacksHandler != null);
    _id = platformViewsRegistry.getNextPlatformViewId();
    _controller = PlatformViewsService.initAndroidView(
      id: _id,
      viewType: 'plugins.kraken/webview',
      // WebView content is not affected by the Android view's layout direction,
      // we explicitly set it here so that the widget doesn't require an ambient
      // directionality.
      layoutDirection: TextDirection.rtl,
      creationParams: MethodChannelWebViewPlatform.creationParamsToMap(creationParams),
      creationParamsCodec: const StandardMessageCodec(),
      onFocus: onFocus,
    );

    _controller.addOnPlatformViewCreatedListener((int id) {
      if (onWebViewPlatformCreated != null) {
        onWebViewPlatformCreated(MethodChannelWebViewPlatform(
            id, webViewPlatformCallbacksHandler));
      }
    });

    return RenderAndroidView(
      viewController: _controller,
      hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      gestureRecognizers: gestureRecognizers,
    );
  }

  @override
  Future<bool> clearCookies() => MethodChannelWebViewPlatform.clearCookies();
}
