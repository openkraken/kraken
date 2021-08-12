/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/launcher.dart';

class UriInterceptor {

  static RegExp exp = RegExp("^([a-z][a-z\d\+\-\.]*:)?\/\/");

  Uri parse(int contextId, Uri uri) {
    String path = uri.toString();

    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId)!;

    String href = controller.href;
    Uri uriHref = Uri.parse(href);

    // Treat empty scheme as https.
    if (path.startsWith('//')) {
      path = 'https:' + path;
    }

    if (!exp.hasMatch(path)) {
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

    return Uri.parse(path);
  }
}
