/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';

const String ANCHOR = 'A';

const Map<String, dynamic> _defaultStyle = {DISPLAY: INLINE};

class AnchorElement extends Element {
  String _href;
  String _target;

  AnchorElement(int targetId, ElementManager elementManager)
      : super(targetId, elementManager, tagName: ANCHOR, defaultStyle: _defaultStyle) {
    addEvent(EventType.click);
  }

  void handleClick(Event event) {
    super.handleClick(event);
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

        return KrakenNavigationType.linkActivated;
      default:
        return KrakenNavigationType.other;
    }
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
