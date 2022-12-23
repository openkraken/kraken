/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

class UriParser {
  Uri resolve(Uri base, Uri relative) {
    final Uri uri = base.resolveUri(relative);
    assert(uri.hasScheme);
    return uri;
  }
}
