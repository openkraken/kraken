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

  it('should receive from native side', (done) => {
    const objectElement = document.createElement('object');
    setElementStyle(objectElement, {
      width: '750px',
      height: '400px',
    });

    setAttributes(objectElement, {
      data: 'https://videocdn.taobao.com/oss/ali-video/1fa0c3345eb3433b8af7e995e2013cea/1458900536/video.mp4',
    });
    objectElement.addEventListener('customevent', function handler(event: CustomEvent) {
      objectElement.removeEventListener('customevent', handler);
      expect(event.type).toEqual('customevent');
      expect(event.detail).toEqual('hello world');
      done();
    });
    document.body.appendChild(objectElement);
  });
});

