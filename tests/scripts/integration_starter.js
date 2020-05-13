const {spawn, fork} = require('child_process');
const path = require('path');

function startWebSocketServer() {
  const file = path.join(__dirname, 'ws_server.js');
  fork(file, [], {
    stdio: 'inherit'
  });
}

function startIntegrationTest() {
  const tester = spawn('flutter', ['driver', '--target=integration/app.dart', '--driver=integration/app_test.dart', '-d', 'macos'], {
    env: {
      ...process.env,
      KRAKEN_LIBRARY_PATH: path.join(__dirname, '../../targets/darwin/lib')
    },
    cwd: process.cwd(),
    stdio: 'inherit'
  });
  tester.on('close', () => {
    process.exit(0);
  });
  tester.on('error', (error) => {
    console.error(error);
    process.exit(1);
  });
}

startIntegrationTest();
startWebSocketServer();
