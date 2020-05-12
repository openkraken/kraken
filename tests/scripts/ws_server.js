const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8399 });

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    ws.send(`receive: ${message}`);
  });

  ws.on('close', () => {
    console.log('connection closed');
  });

  ws.send('something');
});

process.on('uncaughtException', () => {
  wss.close();
});
process.on('exit', () => {
  wss.close();
});
