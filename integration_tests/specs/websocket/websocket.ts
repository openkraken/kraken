describe('WebSocket', () => {
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
  });

  it('trigger on error when failed connection', (done) => {
    let ws = new WebSocket('ws://127.0.0.1');
    ws.onerror = () => {
      done();
    };
    ws.onmessage = () => {
      throw new Error('should not connected');
    };
    ws.onopen = () => {
      throw new Error('should not be opened');
    };
  });

  it('trigger on onerror when server shutdown', (done) => {
    let ws = new WebSocket('ws://127.0.0.1:8400');
    ws.onclose = () => {
      done();
    };
    ws.onerror = () => {
      done();
    };
  });
});
