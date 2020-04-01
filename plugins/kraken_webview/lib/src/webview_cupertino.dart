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

/// Builds an iOS webview.
///
/// This is used as the default implementation for [WebViewElement.platform] on iOS. It uses
/// a [UiKitView] to embed the webview in the widget hierarchy, and uses a method channel to
/// communicate with the platform code.
class CupertinoWebView implements WebViewPlatform {
  UiKitViewController _controller;
  RenderUiKitView _renderUiKitView;
  int _id;

  Future<UiKitViewController> getUiKitViewController(int id,
      CreationParams creationParams) async {
    return PlatformViewsService.initUiKitView(
      id: id,
      viewType: 'plugins.flutter.io/webview',
      layoutDirection: TextDirection.rtl,
      creationParams: MethodChannelWebViewPlatform.creationParamsToMap(creationParams),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  @override
  RenderBox buildRenderBox({
    CreationParams creationParams,
    @required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
    WebViewPlatformCreatedCallback onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    VoidCallback onFocus,
  }) {
    _id = platformViewsRegistry.getNextPlatformViewId();

    // Expanded render box.
    RenderConstrainedBox _expandHolder = RenderConstrainedBox(
      additionalConstraints: BoxConstraints.tightFor(),
    );

    // Async get uikit view controller.
    getUiKitViewController(_id, creationParams)
      .then((UiKitViewController controller) {
        _controller = controller;
        if (onWebViewPlatformCreated != null) {
          onWebViewPlatformCreated(MethodChannelWebViewPlatform(
              _id, webViewPlatformCallbacksHandler));
        }
        _expandHolder.child = RenderUiKitView(
          viewController: _controller,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          gestureRecognizers: gestureRecognizers,
        );
      });

    return _expandHolder;
  }

  @override
  Future<bool> clearCookies() => MethodChannelWebViewPlatform.clearCookies();
}
