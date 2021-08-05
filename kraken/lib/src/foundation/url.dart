/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:dio/dio.dart';
import 'package:kraken/launcher.dart';


abstract class URLClient {
  @override
  String parser(String url, String originURL);
}

class URLParser {
  String _url = '';
  int? _contextId;

  URLParser(String url, { int? contextId }) {
    String path = url;
    String originURL = url;

    if(contextId != null) {
      _contextId = contextId;
      KrakenController controller = KrakenController.getControllerOfJSContextId(_contextId)!;
      URLClient? urlClient = controller.urlClient;

      // Treat empty scheme as https.
      if (path.startsWith('//')) path = 'https' + path;

      RegExp exp = RegExp("^([a-z][a-z\d\+\-\.]*:)?\/\/");
      if (!exp.hasMatch(path) && _contextId != null && path.startsWith('//')) {
        // relative path.
        KrakenController controller = KrakenController.getControllerOfJSContextId(_contextId)!;
        Uri uriHref = Uri.parse(controller.href);
        String href = controller.href;
        if (path.startsWith('/')) {
          path = uriHref.scheme + '://' + uriHref.host + ':' + uriHref.port.toString() + path;
        } else {
          path = href.substring(0, href.lastIndexOf('/')) + '/' + path;
        }
      }

      if (urlClient != null) {
        path = urlClient.parser(url, originURL);
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
