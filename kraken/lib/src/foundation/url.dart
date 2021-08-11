/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/launcher.dart';

abstract class UriInterceptor {
  Uri parse(Uri uri, Uri originUri);
}

class UriParser {
  int _contextId;

  static RegExp exp = RegExp("^([a-z][a-z\d\+\-\.]*:)?\/\/");

  UriParser(contextId) : _contextId = contextId;

  UriInterceptor? _uriInterceptor;

  void registerInterceptor(UriInterceptor? uriInterceptor) {
    _uriInterceptor = uriInterceptor;
  }

  void disposeInterceptor() {
    _uriInterceptor = null;
  }

  Uri parse(Uri uri) {
    String path = uri.toString();

    KrakenController controller = KrakenController.getControllerOfJSContextId(_contextId)!;

    String href = controller.href;
    Uri uriHref = Uri.parse(href);

    // Treat empty scheme as https.
    if (path.startsWith('//')) {
      path = 'https:' + path;
    }

    if (!exp.hasMatch(path) && _contextId != null) {
      // relative path.
      if (path.startsWith('/')) {
        path = uriHref.scheme + '://' + uriHref.host + ':' + uriHref.port.toString() + path;
      } else {
        int lastPath = href.lastIndexOf('/');
        if (lastPath >= 0) {
          path = href.substring(0, href.lastIndexOf('/')) + '/' + path;
        }
      }
    }

    if (_uriInterceptor != null) {
      return _uriInterceptor!.parse(Uri.parse(path), uri);
    }

    return Uri.parse(path);
  }
}
