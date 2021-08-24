import 'package:kraken/foundation.dart';
import 'package:test/test.dart';

void main() {
  group('environment', () {
    test('getKrakenTemporaryPath()', () async {
      String tempPath = await getKrakenTemporaryPath();
      expect(tempPath, './temp');
    });
  });
}
