/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/launcher.dart';
import 'package:kraken/foundation.dart';

class URLParser {
  String _url = '';
  int? _contextId;

  URLParser(String url, { int? contextId }) {
    String path = url;

    if(contextId != null) {
      _contextId = contextId;
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
        path = httpClientInterceptor.customURLParser(path, url);
      }
    }

    _url = path;
  }

  Uri get url {
    return Uri.parse(_url);
  }

  String toString() {
    return _url;
  }
}
