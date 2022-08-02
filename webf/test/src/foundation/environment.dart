/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:test/test.dart';
import 'package:webf/foundation.dart';

void main() {
  group('environment', () {
    test('getWebFTemporaryPath()', () async {
      String tempPath = await getWebFTemporaryPath();
      expect(tempPath, './temp');
    });
  });
}
