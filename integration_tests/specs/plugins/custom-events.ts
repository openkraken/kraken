describe('custom-events', () => {
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