/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/launcher.dart';

class URLParser {
  String _url = '';
  int? _contextId;

  URLParser(String url, { int? contextId }) {
    String path = url;
    if (contextId != null) {
      _contextId = contextId;
    }

    // Treat empty scheme as https.
    if (path.startsWith('//')) path = 'https' + path;

    RegExp exp = RegExp("^([a-z][a-z\d\+\-\.]*:)?\/\/");
    if (!exp.hasMatch(path) && _contextId != null) {
      // relative path.
      KrakenController controller = KrakenController.getControllerOfJSContextId(_contextId)!;
      Uri uriHref = Uri.parse(controller.href);
      path = uriHref.scheme + '://' + uriHref.host + ':' + uriHref.port.toString() + path;
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
