/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';

const String ANCHOR = 'A';

class AnchorElement extends Element {
  String _href;
  String _target;

  final Pointer<NativeAnchorElement> nativeAnchorElement;

  AnchorElement(int targetId, this.nativeAnchorElement, ElementManager elementManager)
      : super(targetId, nativeAnchorElement.ref.nativeElement, elementManager, tagName: ANCHOR) {
    addEvent(EVENT_CLICK);
  }

  void dispatchClick(Event event) {
    dispatchEvent(event);
    if (_href == null) return;

    Uri uri = Uri.parse(_href);
    KrakenController rootController = elementManager.controller.view.rootController;
    String sourceUrl = rootController.bundleURL;
    String scheme;
    if (!uri.hasScheme) {
      if (sourceUrl != null) {
        Uri sourceUri = Uri.parse(sourceUrl);
        scheme = sourceUri.scheme;
      } else {
        scheme = 'http';
      }
    } else {
      scheme = uri.scheme;
    }
    elementManager.controller.view.handleNavigationAction(sourceUrl, _href, _getNavigationType(scheme));
  }

  KrakenNavigationType _getNavigationType(String scheme) {
    switch (scheme) {
      case 'http':
      case 'https':
      case 'file':
        if (_target == null || _target == '_self') {
          return KrakenNavigationType.reload;
        }
    }

    return KrakenNavigationType.navigate;
  }

  @override
  void setProperty(String key, dynamic value) {
    super.setProperty(key, value);
    switch (key) {
      case 'href':
        _href = value;
        break;
      case 'target':
        _target = value;
        break;
      default:
    }
  }

  @override
  void removeProperty(String key) {
    super.removeProperty(key);

    switch (key) {
      case 'href':
        _href = null;
        break;
      case 'target':
        _target = null;
        break;
      default:
    }
  }
}
