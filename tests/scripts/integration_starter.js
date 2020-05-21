const {spawn, fork} = require('child_process');
const path = require('path');
const {startWsServer} = require('./ws_server');
const isPortReachable = require('is-port-reachable');

function startIntegrationTest() {
  const tester = spawn('flutter', ['driver', '--target=integration/app.dart', '--driver=integration/app_test.dart', '-d', 'macos'], {
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
