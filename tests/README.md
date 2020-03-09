# Kraken test framework

## Dart Unit test

1. Simply use flutter test command.
2. More to see https://flutter.dev/docs/cookbook/testing/unit/introduction
3. Package test usage: https://pub.dev/packages/test

## JS API Unit Test

1. An JS wrapper of dart unit test framework.
2. Similar to jest framework usage.
3. Support most jest framework apis: `describe`, `it`, `beforeEach`, `afterEach`, `beforeAll`, `afterAll`.
4. Support async operation by return a promise object from `it`. 

#### Before Start (macOS user only)
1. need to remove flutter_tester executable file's signature.

```bash
codesign --remove-signature /path/to/flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester
```

2. Make sure `KRAKEN_LIBRARY_PATH` is exist in your env.

```
export KRAKEN_LIBRARY_PATH=/path/to/kraken/targets/darwin/debug/lib
```

## Integration test

1. We use flutter integration test to inject a running app.dart.
2. Each js file in fixtures is a test case payload.
3. Each case executed in serial.
4. app_test.dart will drive app.dart to run the test.
5. Compare detection screenshot content.
6. More to see https://flutter.dev/docs/cookbook/testing/integration/introduction

## Usage

+ **intergration test**: npm run test 
+ **dart unit test**: npm run unit
+ **js API unit test**: npm run jsUnit
