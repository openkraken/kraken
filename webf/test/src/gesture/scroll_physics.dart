/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io' show Platform;

import 'package:test/test.dart';
import 'package:webf/src/gesture/scroll_physics.dart';

// Only for test.
class TestScrollPhysics extends ScrollPhysics {}

void main() {
  group('ScrollPhysics', () {
    test('createScrollPhysics', () {
      ScrollPhysics scrollPhysics = ScrollPhysics.createScrollPhysics();
      // In test env, that should be macos env.
      expect(Platform.operatingSystem, 'linux');
      expect(scrollPhysics.runtimeType.toString(), 'ClampingScrollPhysics');
    });

    test('ScrollPhysics Factory', () {
      // ScrollPhysics
      ScrollPhysics.scrollPhysicsFactory = (ScrollPhysics? parent) {
        return TestScrollPhysics();
      };

      ScrollPhysics scrollPhysics = ScrollPhysics.createScrollPhysics();
      expect(scrollPhysics.runtimeType.toString(), 'TestScrollPhysics');

      ScrollPhysics.scrollPhysicsFactory = null;
    });
  });
}
