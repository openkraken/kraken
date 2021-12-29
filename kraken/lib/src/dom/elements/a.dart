/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/gestures.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';

const String ANCHOR = 'A';

class AnchorElement extends Element {
  Uri? _hrefUri;
  String get _href {
    if (_hrefUri == null) return '';
    return _hrefUri!.toString();
  }
  set _href(String? value) {
    if (value == null) return;
    _hrefUri = Uri.parse(value);
  }

  String? _target;

  AnchorElement(EventTargetContext? context)
      : super(context) {
    addEvent(EVENT_CLICK);
  }

  String get pathname {
    if (_hrefUri == null) return '';
    return _hrefUri!.path;
  }
  set pathname(String value) {
    if (_hrefUri == null) return;
    _hrefUri = _hrefUri!.replace(path: value);
  }

  String get hash {
    if (_hrefUri == null) return '';
    return _hrefUri!.fragment;
  }
  set hash(String value) {
    if (_hrefUri == null) return;
    _hrefUri = _hrefUri!.replace(fragment: value);
  }

  String get host {
    if (_hrefUri == null) return '';
    return _hrefUri!.host + ':' + (_hrefUri!.hasPort ? _hrefUri!.port.toString() : '');
  }
  set host(String value) {
    if (_hrefUri == null) return;

    if(value.contains(':')) {
      String host = value.split(':')[0];
      String port = value.split(':')[1];
      _hrefUri = _hrefUri!.replace(host: host, port: int.parse(port));
    } else {
      _hrefUri = _hrefUri!.replace(host: value);
    }
  }

  String get origin {
    if (_hrefUri == null) return '';
    return _hrefUri!.origin;
  }

  String get hostname {
    if (_hrefUri == null) return '';
    return _hrefUri!.host;
  }
  set hostname(String value) {
    if (_hrefUri == null) return;
    _hrefUri = _hrefUri!.replace(host: value);
  }

  String get port {
    if (_hrefUri == null) return '';
    return _hrefUri!.port.toString();
  }
  set port(String value) {
    if (_hrefUri == null) return;
    _hrefUri = _hrefUri!.replace(port: int.parse(value));
  }

  String get protocol {
    if (_hrefUri == null) return '';
    return _hrefUri!.scheme + ':';
  }
  set protocol(String value) {
    if (_hrefUri == null) return;
    if (value.endsWith(':')) {
      value = value.substring(0, value.length - 1);
    }
    _hrefUri = _hrefUri!.replace(scheme: value);
  }

  @override
  void handleMouseEvent(String eventType, TapUpDetails details) {
    super.handleMouseEvent(eventType, details);

    String? href = _href;
    if (href.isNotEmpty) {
      String baseUrl = ownerDocument.controller.href;
      Uri baseUri = Uri.parse(baseUrl);
      Uri resolvedUri = ownerDocument.controller.uriParser!.resolve(baseUri, Uri.parse(href));
      ownerDocument.controller.view.handleNavigationAction(
          baseUrl, resolvedUri.toString(), _getNavigationType(resolvedUri.scheme));
    }
  }

  KrakenNavigationType _getNavigationType(String scheme) {
    switch (scheme.toLowerCase()) {
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
  getProperty(String key) {
    switch (key) {
      case 'pathname':
        return pathname;
      case 'href':
        return _href;
      case 'target':
        return _target;
      case 'accessKey':
        return '';
      case 'hash':
        return hash;
      case 'host':
        return host;
      case 'hostname':
        return hostname;
      case 'origin':
        return origin;
      case 'port':
        return port;
      case 'protocol':
        return protocol;
      default:
        return super.getProperty(key);
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
      case 'pathname':
        pathname = value;
        break;
      case 'hash':
        hash = value;
        break;
      case 'host':
        host = value;
        break;
      case 'hostname':
        hostname = value;
        break;
      case 'port':
        port = value;
        break;
      case 'protocol':
        protocol = value;
        break;
    }
  }
}
