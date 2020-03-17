describe('Tags video', () => {
  it('basic', done => {
    const container1 = document.createElement('div');
    setStyle(container1, {
      height: '500rpx',
    });

    document.body.appendChild(container1);

    const video = document.createElement('video');
    setStyle(video, {
      width: '750rpx',
      height: '400rpx',
    });

    setAttributes(video, {
      autoPlay: true,
      src:
        'https://videocdn.taobao.com/oss/ali-video/1fa0c3345eb3433b8af7e995e2013cea/1458900536/video.mp4',
    });

    video.addEventListener('canplay', () => {
      done();
    });

    container1.appendChild(video);

    const pauseBtn = document.createElement('div');
    pauseBtn.appendChild(document.createTextNode('pause button'));
    pauseBtn.addEventListener('click', () => {
      video.pause();
    });
    container1.appendChild(pauseBtn);

    const playBtn = document.createElement('div');
    playBtn.appendChild(document.createTextNode('playBtn button'));
    playBtn.addEventListener('click', () => {
      video.play();
    });
    container1.appendChild(playBtn);
  });
});
