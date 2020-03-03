import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can instantiate Location object', (WidgetTester tester) async {
    final Location location = Location();
    expect(location, isNotNull);
  });
}
