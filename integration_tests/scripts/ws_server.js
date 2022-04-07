/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const WebSocket = require('ws');

exports.startWsServer = function(port) {
  const simpleServer = new WebSocket.Server({ port: port });

  let unstableServer;

  // auto closed and recreate ws server.
  // used to test failed connection
  setInterval(() => {
    if (!unstableServer) {
      unstableServer = new WebSocket.Server({ port: port + 1 });
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

};
