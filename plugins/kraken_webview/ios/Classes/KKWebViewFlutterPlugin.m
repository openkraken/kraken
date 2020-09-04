// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "KKWebViewFlutterPlugin.h"
#import "FLTCookieManager.h"
#import "FlutterWebView.h"

@implementation KKWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTWebViewFactory* webviewFactory =
      [[FLTWebViewFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:webviewFactory withId:@"plugins.kraken/webview"];
  [FLTCookieManager registerWithRegistrar:registrar];
}

@end
