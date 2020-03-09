# Kraken test framework

## Unit test

1. Simply use flutter test command.
2. More to see https://flutter.dev/docs/cookbook/testing/unit/introduction
3. Package test usage: https://pub.dev/packages/test

## Integration test

1. We use flutter integration test to inject a running app.dart.
2. Each js file in fixtures is a test case payload.
3. Each case executed in serial.
4. app_test.dart will drive app.dart to run the test.
5. Compare detection screenshot content.
6. More to see https://flutter.dev/docs/cookbook/testing/integration/introduction

## Usage

- npm run test
