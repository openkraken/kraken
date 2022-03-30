/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const { spawn, spawnSync } = require('child_process');
const path = require('path');
const { startWsServer } = require('./ws_server');
const isPortReachable = require('is-port-reachable');

// Dart null safety error didn't report in dist binaries. Should run integration test with flutter run directly.
function startIntegrationTest() {
  const shouldSkipBuild = /skip\-build/.test(process.argv);
  if (!shouldSkipBuild) {
    console.log('Building integration tests macOS application from "lib/main.dart"...');
    spawnSync('flutter', ['build', 'macos', '--debug', '--target=lib/plugin.dart'], {
      stdio: 'inherit'
    });
  }

  const testExecutable = path.join(__dirname, '../build/macos/Build/Products/Debug/tests.app/Contents/MacOS/tests');
  const tester = spawn(testExecutable, [], {
    env: {
      ...process.env,
      KRAKEN_ENABLE_TEST: 'true',
      KRAKEN_TEST_DIR: path.join(__dirname, '../')
    },
    cwd: process.cwd(),
    stdio: 'inherit'
  });
  tester.on('close', (code) => {
    process.exit(code);
  });
  tester.on('error', (error) => {
    console.error(error);
    process.exit(1);
  });
  tester.on('exit', (code, signal) => {
    if (code != 0) {
      process.exit(1);
    }
  });
}

(async () => {
  startIntegrationTest();
  const PORT = 8399;
  if (!await isPortReachable(PORT)) {
    startWsServer(PORT);
  }
})();
