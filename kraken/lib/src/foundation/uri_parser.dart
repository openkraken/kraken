/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
final RegExp _schemeRegExp = RegExp('^([a-z][a-z\d\+\-\.]*:)?\/\/');
const String _defaultScheme = 'https:';

class UriParser {

  String resolve(Uri baseUri, Uri relativeUri) {
    String base = baseUri.toString();

    // Treat empty scheme as https.
    if (base.startsWith('//')) {
      return _defaultScheme + base;
    } else if (!_schemeRegExp.hasMatch(base)) {
      String relative = relativeUri.toString();
      // Relative path.
      if (base.startsWith('/')) {
        return relativeUri.scheme + '://' + relativeUri.host + ':' + relativeUri.port.toString() + base;
      } else {
        int lastPath = relative.lastIndexOf('/');
        if (lastPath >= 0) {
          return base.substring(0, base.lastIndexOf('/')) + '/' + base;
        }
      }
    }

    // Noop.
    return base;
  }
}
