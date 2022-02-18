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
      String baseUrl = ownerDocument.controller.url;
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
  // URL decomposition IDL attributes
  // - attribute DOMString protocol;
  // - attribute DOMString host;
  // - attribute DOMString hostname;
  // - attribute DOMString port;
  // - attribute DOMString pathname;
  // - attribute DOMString search;
  // - attribute DOMString hash;
  // The IDL attribute relList must reflect the rel content attribute.
  @override
  getProperty(String key) {
    switch (key) {
      // The IDL attributes href, target, rel, media, hreflang, and type,
      // must reflect the respective content attributes of the same name.
      case 'href':
      case 'target':
      case 'rel':
      case 'type':
        return _DOMString(attributes[key]);

      // The a element also supports the complement of URL decomposition IDL attributes,
      // protocol, host, port, hostname, pathname, search, and hash.
      // These must follow the rules given for URL decomposition IDL attributes,
      // with the input being the result of resolving the element's href attribute relative
      // to the element, if there is such an attribute and resolving it is successful, or
      // the empty string otherwise; and the common setter action being the same as setting
      // the element's href attribute to the new output value.
      case 'protocol':
        return _protocol;
      case 'host':
        return _host;
      case 'hostname':
        return _hostname;
      case 'port':
        return _port;
      case 'pathname':
        return _pathname;
      case 'search':
        return _search;
      case 'hash':
        return _hash;
      default:
        super.getProperty(key);
    }
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    switch (key) {
      case 'href':
        _resolveHyperlink();
        break;
      case 'protocol':
        _protocol = value;
        break;
      case 'host':
        _host = value;
        break;
      case 'hostname':
        _hostname = value;
        break;
      case 'port':
        _port = value;
        break;
      case 'pathname':
        _pathname = value;
        break;
      case 'search':
        _search = value;
        break;
      case 'hash':
        _hash = value;
        break;
    }
  }

  String get _protocol => _DOMString(_resolvedHyperlink?.scheme) + ':';
  set _protocol(String value) {
    if (_resolvedHyperlink == null) return;

    if (!value.endsWith(':')) {
      value += ':';
      attributes['protocol'] = value;
    }

    // Remove the ending `:`
    String scheme = value.substring(0, value.length - 1);
    _resolvedHyperlink = _resolvedHyperlink!.replace(scheme: scheme);
    _reflectToAttributeHref();
  }

  String get _host {
    String? host;
    Uri? resolved = _resolvedHyperlink;
    if (resolved != null) {
      host = resolved.host + ':' + (resolved.hasPort ? resolved.port.toString() : '');
    }
    return _DOMString(host);
  }
  set _host(String value) {
    if (_resolvedHyperlink == null) return;
    String host = value;
    String port = _port;

    // If input host including port.
    if (value.contains(':')) {
      List<String> split = value.split(':');
      host = split[0];
      port = split[1];
    }

    _resolvedHyperlink = _resolvedHyperlink!.replace(host: host, port: int.parse(port));
    _reflectToAttributeHref();
  }

  String get _hostname => _DOMString(_resolvedHyperlink?.host);
  set _hostname(String value) {
    if (_resolvedHyperlink == null) return;
    _resolvedHyperlink = _resolvedHyperlink!.replace(host: value);
    _reflectToAttributeHref();
  }

  String get _port => _DOMString(_resolvedHyperlink?.port.toString());
  set _port(String value) {
    if (_resolvedHyperlink == null) return;
    int? port = int.tryParse(value);
    if (port != null) {
      _resolvedHyperlink = _resolvedHyperlink!.replace(port: port);
      _reflectToAttributeHref();
    }
  }

  String get _pathname => _DOMString(_resolvedHyperlink?.path);
  set _pathname(String value) {
    if (_resolvedHyperlink == null) return;
    _resolvedHyperlink = _resolvedHyperlink!.replace(path: value);
    _reflectToAttributeHref();
  }

  String get _search {
    String? search;
    String? query = _resolvedHyperlink?.query;
    if (query != null && query.isNotEmpty) {
      search = '?' + query;
    }
    return _DOMString(search);
  }
  set _search(String value) {
    if (_resolvedHyperlink == null) return;
    // Remove starting `?`.
    if (value.startsWith('?')) {
      value = value.substring(1);
    }

    _resolvedHyperlink = _resolvedHyperlink!.replace(query: value);
    _reflectToAttributeHref();
  }

  String get _hash => _DOMString(_resolvedHyperlink?.fragment);
  set _hash(String value) {
    if (_resolvedHyperlink == null) return;
    _resolvedHyperlink = _resolvedHyperlink!.replace(fragment: value);
    _reflectToAttributeHref();
  }

  // Web IDL attributes must return DOMString, it's a non-null value.
  String _DOMString(String? input) {
    return input ?? '';
  }

  Uri? _resolvedHyperlink;
  // Resolve the href into uri entity, for convenience of URL decomposition IDL attributes to get value.
  void _resolveHyperlink() {
    String? href = attributes['href'];
    if (href != null) {
      String base = ownerDocument.controller.url;
      try {
        _resolvedHyperlink = ownerDocument.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(href));
      } finally {
        // Ignoring the failure of resolving.
      }
    }
  }

  // If URL decomposition IDL attributes changed, we should sync href attribute to changed value.
  void _reflectToAttributeHref() {
    if (_resolvedHyperlink != null) {
      attributes['href'] = _resolvedHyperlink.toString();
    }
  }
}
