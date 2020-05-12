describe('simple websocket usage', () => {
  it('closed before create connection', (done) => {
    let ws = new WebSocket('ws://127.0.0.1:8399');
    ws.onopen = () => {
      throw new Error('should not connected');
    };
    ws.onerror = () => {
      throw new Error('connection failed');
    };
    ws.onclose = () => {
      done();
    };
    ws.close();
  });

  it('send and receive', (done) => {
    let ws = new WebSocket('ws://127.0.0.1:8399');
    ws.onopen = () => {
      ws.send('helloworld');
    };
    let index = 0;
    ws.onmessage = (event) => {
      if (index === 0) {
        expect(event.data).toBe('something');
      } else if (index === 1) {
        expect(event.data).toBe('receive: helloworld');
        done();
      }
      index++;
    }
    ws.close();
  });
});
