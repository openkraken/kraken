const WebSocket = require('ws');

const simpleServer = new WebSocket.Server({ port: 8399 });

let unstableServer;

// auto closed and recreate ws server.
// used to test failed connection
setInterval(() => {
  if (!unstableServer) {
    unstableServer = new WebSocket.Server({ port: 8400 });
  } else {
    // trigger server close and notify all clients.
    unstableServer.close();
    unstableServer = null;
  }
}, 200);

simpleServer.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    ws.send(`receive: ${message}`);
  });

  ws.on('close', () => {
  });

  ws.send('something');
});

function closeSimpleServer(e) {
  console.log(e);
  simpleServer.close();
  process.exit(0);
}

process.on('uncaughtException', closeSimpleServer);
process.on('exit', () => closeSimpleServer);
process.on('disconnect', () => closeSimpleServer);
