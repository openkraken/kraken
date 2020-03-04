/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken_webview/kraken_webview.dart' show WebViewElement;

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
}
