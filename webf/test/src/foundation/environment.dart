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
