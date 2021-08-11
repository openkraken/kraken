/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/launcher.dart';
import 'package:kraken/foundation.dart';

class UriParser {
  String _url = '';
  int _contextId;

  UriParser(contextId) : _contextId = contextId;

  Uri parse(Uri uri) {
    String path = uri.toString();

    KrakenController controller = KrakenController.getControllerOfJSContextId(_contextId)!;
    HttpClientInterceptor? httpClientInterceptor = controller.httpClientInterceptor;
    Uri uriHref = Uri.parse(controller.href);
    String href = controller.href;

    // Treat empty scheme as https.
    if (path.startsWith('//')) {
      path = 'https:' + path;
    }

    RegExp exp = RegExp("^([a-z][a-z\d\+\-\.]*:)?\/\/");
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

    if (httpClientInterceptor != null) {
      path = httpClientInterceptor.customURLParser(path, uri.toString());
    }

    return Uri.parse(path);
  }

  Uri get url {
    return Uri.parse(_url);
  }

  String toString() {
    return _url;
  }
}
