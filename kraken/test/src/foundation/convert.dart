import 'package:kraken/foundation.dart';
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
