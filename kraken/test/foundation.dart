import 'package:test/test.dart';

import 'src/foundation/http_cache.dart' as http_cache;
import 'src/foundation/http_client_interceptor.dart' as http_client_interceptor;
import 'src/foundation/environment.dart' as environment;
import 'src/foundation/uri_parser.dart' as uri_parser;

void main() {
  group('foundation', () {
    http_cache.main();
    http_client_interceptor.main();
    environment.main();
    uri_parser.main();
  });
}
