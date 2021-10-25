describe('Tags object', () => {
  it('basic', done => {

    const objectElement = document.createElement('object');
    setElementStyle(objectElement, {
      width: '750px',
      height: '400px',
    });

    setAttributes(objectElement, {
      data: 'https://videocdn.taobao.com/oss/ali-video/1fa0c3345eb3433b8af7e995e2013cea/1458900536/video.mp4',
    });
    document.body.appendChild(objectElement);

    setTimeout(async () => {
      done();
    }, 3000);
  });
});
