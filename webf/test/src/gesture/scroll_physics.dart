import 'dart:io' show Platform;
import 'package:kraken/src/gesture/scroll_physics.dart';
import 'package:test/test.dart';

// Only for test.
class TestScrollPhysics extends ScrollPhysics {}

void main() {
  group('ScrollPhysics', () {
    test('createScrollPhysics', () {
      ScrollPhysics scrollPhysics = ScrollPhysics.createScrollPhysics();
      // In test env, that should be macos env.
      expect(Platform.operatingSystem, 'macos');
      expect(scrollPhysics.runtimeType.toString(), 'BouncingScrollPhysics');
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
