const {spawn, fork, spawnSync} = require('child_process');
const path = require('path');
const {startWsServer} = require('./ws_server');
const isPortReachable = require('is-port-reachable');

function startIntegrationTest() {
  console.log('Building macos application...');
  spawnSync('flutter', ['build', 'macos', '--debug', '--target=integration/app.dart']);

  const testExecutable = path.join(__dirname, '../build/macos/Build/Products/Debug/tests.app/Contents/MacOS/tests');
  const tester = spawn(testExecutable, [], {
    env: {
      ...process.env,
      KRAKEN_LIBRARY_PATH: path.join(__dirname, '../../targets/darwin/lib')
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
}

(async () => {
  startIntegrationTest();
  const PORT = 8399;
  if (!await isPortReachable(PORT)) {
    startWsServer(PORT);
  }
})();
