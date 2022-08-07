/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/foundation.dart';
import 'package:test/test.dart';

void main() {
  group('Convert', () {
    test('utf8 decode basic', () async {
      String spec = 'Hello World!';
      List<int> rawData = spec.codeUnits;
      String decoded = await resolveStringFromData(rawData);

      expect(decoded, spec);
    });
  });
}
