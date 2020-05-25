describe('CustomEvent', () => {
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
    document.body.addEventListener('customEvent', (event: CustomEvent) => {
      expect(event.detail).toEqual('detailMessage');
      done();
    });
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
  