describe('CustomEvent', () => {
  function _listenEvent(done, event: CustomEvent) {
    expect(event.detail).toEqual('detailMessage');
    if (done) {
      document.body.removeEventListener('customEvent', _listenEvent.bind(document.body, null));
      done();
    }
  }

  it('should exist CustomEvent global object', () => {
    expect(CustomEvent).toBeDefined();
    expect(() => {
      new CustomEvent('test');
    }).not.toThrow();
  });

  it('should work as expected', () => {
    let customEvent = new CustomEvent('customEvent', { detail: 'detailMessage' });
    expect(customEvent.detail).toEqual('detailMessage');
  });

  it('should dispatch custom event', (done) => {
    document.body.addEventListener('customEvent', _listenEvent.bind(document.body, done));
    document.body.dispatchEvent(new CustomEvent('customEvent', {
      detail: 'detailMessage'
    }));
  });

  it('should call initCustomEvent method', () => {
    let customEvent = new CustomEvent('customEvent', { detail: 'detailMessage' });
    customEvent.initCustomEvent('newCustomEvent', false, false, 'newDetail');
    expect(customEvent.type).toEqual('newCustomEvent');
    expect(customEvent.detail).toEqual('newDetail');
  });
});

