/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/gestures.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';

const String ANCHOR = 'A';
const String _TARGET_SELF = 'self';

class AnchorElement extends Element {
  AnchorElement(EventTargetContext? context)
      : super(context) {
    addEvent(EVENT_CLICK);
  }

  @override
  void handleMouseEvent(String eventType, TapUpDetails details) {
    super.handleMouseEvent(eventType, details);

    String? href = attributes['href'];
    if (href != null && href.isNotEmpty) {
      String baseUrl = ownerDocument.controller.currentUrl;
      Uri baseUri = Uri.parse(baseUrl);
      Uri resolvedUri = ownerDocument.controller.uriParser!.resolve(baseUri, Uri.parse(href));
      ownerDocument.controller.view.handleNavigationAction(
          baseUrl, resolvedUri.toString(), _getNavigationType(resolvedUri.scheme));
    }
  }

  String get _target => attributes['target'] ?? _TARGET_SELF;

  KrakenNavigationType _getNavigationType(String scheme) {
    switch (scheme.toLowerCase()) {
      case 'http':
      case 'https':
      case 'file':
        if (_target == _TARGET_SELF) {
          return KrakenNavigationType.reload;
        }
    }

    return KrakenNavigationType.navigate;
  }

  // Supported properties:
  // - href: the address of the hyperlink.
  // - target: Specifies how the content of the open target URL is displayed to the user.
  //           Only used when the href attribute is present.
  // - rel: Specifies the relationship between the current document and the target URL.
  //        Only used when the href attribute is present.
  // - type: The MIME type of the linked document.
  @override
  getProperty(String key) {
    switch (key) {
      case 'href':
      case 'rel':
      case 'type':
        return attributes[key] ?? '';
      case 'target':
        return _target;
      default:
        super.getProperty(key);
    }
  }
}
