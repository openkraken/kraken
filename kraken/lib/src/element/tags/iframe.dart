/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:async';
import 'dart:convert';

import 'package:kraken/bridge.dart';
import 'package:kraken_webview/kraken_webview.dart';
import 'package:kraken/element.dart';

const String IFRAME = 'IFRAME';

/// The iframe element represents its nested browsing context.
///
/// The src attribute gives the URL of a page that the element's nested browsing
/// context is to contain. The attribute, if present, must be a valid non-empty
/// URL potentially surrounded by spaces. If the itemprop attribute is specified
/// on an iframe element, then the src attribute must also be specified.
///
/// DOM interface:
// [Exposed=Window]
// interface HTMLIFrameElement : HTMLElement {
//   [HTMLConstructor] constructor();
//
//   [CEReactions] attribute USVString src;
//   [CEReactions] attribute DOMString srcdoc;
//   [CEReactions] attribute DOMString name;
//   [SameObject, PutForwards=value] readonly attribute DOMTokenList sandbox;
//   [CEReactions] attribute DOMString allow;
//   [CEReactions] attribute boolean allowFullscreen;
//   [CEReactions] attribute boolean allowPaymentRequest;
//   [CEReactions] attribute DOMString width;
//   [CEReactions] attribute DOMString height;
//   [CEReactions] attribute DOMString referrerPolicy;
//   readonly attribute Document? contentDocument;
//   readonly attribute WindowProxy? contentWindow;
//   Document? getSVGDocument();
// };
class IFrameElement extends WebViewElement {
  IFrameElement(int nodeId, Map<String, dynamic> props, List<String> events)
      : super(nodeId, props, events, tagName: IFRAME);

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void onWebViewCreated(WebViewController controller) {
    _controller.complete(controller);
  }

  @override
  void onFocus() {
    dispatchEvent(Event('focus'));
  }

  bool _isFirstLoaded;
  @override
  void onPageStarted(String url) {
    if (_isFirstLoaded) {
      dispatchEvent(Event('unload'));
    }
  }

  @override
  void onPageFinished(String url) {
    _isFirstLoaded = true;
    dispatchEvent(Event('load'));
  }

  @override
  void onPostMessage(String message) {
    MessageEvent event = MessageEvent(message, origin: properties['url']);
    dispatchEvent(event);
  }

  Future<String> _postMessage(String message) {
    String escapedMessage = message?.replaceAll(RegExp('\"', multiLine: true), '\\"');
    String invoker = '''
      window.dispatchEvent(Object.assign(new CustomEvent('message'), {
        data: "${escapedMessage}",
        origin: 'kraken',
      }));
    '''.trim();
    // Wait until controller ready.
    return _controller.future.then((WebViewController controller) {
      return controller.evaluateJavascript(invoker);
    });
  }

  @override
  method(String name, List args) async {
    switch (name) {
      case 'postMessage':
        var firstArg = args[0];
        String message = firstArg?.toString();
        return await _postMessage(message);
      default:
        super.method(name, args);
    }
  }
}
