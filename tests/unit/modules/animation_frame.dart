import 'package:test/test.dart';
import 'package:kraken/src/element/binding.dart';
import 'package:kraken/src/module/animation_frame.dart';

void main() {
  setUp(() {
    ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();
  });

  group('AnimationFrame', () {
    test('requestAnimationFrame should work', () {
      DoubleCallback callback = expectAsync1((ts) {
        expect(ts.runtimeType, double);
      }, count: 1);
      var id = requestAnimationFrame(callback);

      expect(id.runtimeType, int);
    });
  });
}