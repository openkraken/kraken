# Kraken integration tests

## Dart Unit test

1. Simply use flutter test command.
2. More to see https://flutter.dev/docs/cookbook/testing/unit/introduction
3. Package test usage: https://pub.dev/packages/test

## JS API Unit Test

1. An JS wrapper of dart unit test framework.
2. Similar to jest framework usage.
3. Support most jest framework apis: `describe`, `it`, `beforeEach`, `afterEach`, `beforeAll`, `afterAll`.
4. Support async operation by return a promise object from `it`.

## Integration test

1. We use flutter integration test to inject a running app.dart.
2. Each js file in fixtures is a test case payload.
3. Each case executed in serial.
4. app_test.dart will drive app.dart to run the test.
5. Compare detection screenshot content.
6. More to see https://flutter.dev/docs/cookbook/testing/integration/introduction

## Usage

+ **intergration test**: npm run test

### For MacBook Pro 16 inc Users (with dedicated AMD GPU)

Use the following commands to switch your GPU into Intel's integration GPU.

```
sudo pmset -a gpuswitch 0
```

+ 0: Intel's GPU only
+ 1: AMD GPU only
+ 2: dynamic switch

### Run single spec

this above command will execute which spec's name contains "synthesized-baseline-flexbox-001"
```
 KRAKEN_TEST_FILTER="synthesized-baseline-flexbox-001" npm run integration
```
