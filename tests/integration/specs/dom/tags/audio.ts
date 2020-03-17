describe('Element input', () => {
  it('basic', async () => {
    const container1 = document.createElement('div');
    setStyle(container1, {
      height: '500rpx',
    });

    document.body.appendChild(container1);

    const audio = document.createElement('audio');
    setStyle(audio, {
      width: '300px',
      height: '45px',
    });
    setAttributes(audio, {
      controls: true,
      src: 'https://interactive-examples.mdn.mozilla.net/media/examples/t-rex-roar.mp3',
    });

    container1.appendChild(audio);

    const playBtn = document.createElement('div');
    setStyle(playBtn, {
      display: 'inline-block',
      width: '80px',
      height: '30px',
      margin: '0 10px 0 0',
      backgroundColor: '#999',
    });
    playBtn.appendChild(document.createTextNode('play test'));
    playBtn.addEventListener('click', () => {
      audio.play();
    });
    container1.appendChild(playBtn);

    const pauseBtn = document.createElement('div');
    setStyle(pauseBtn, {
      display: 'inline-block',
      width: '80px',
      height: '30px',
      margin: '0 10px 0 0',
      backgroundColor: '#999',
    });
    pauseBtn.appendChild(document.createTextNode('pause test'));
    pauseBtn.addEventListener('click', () => {
      audio.pause();
    });
    container1.appendChild(pauseBtn);

    const seekBtn = document.createElement('div');
    setStyle(seekBtn, {
      display: 'inline-block',
      width: '80px',
      height: '30px',
      margin: '0 10px 0 0',
      backgroundColor: '#999',
    });
    seekBtn.appendChild(document.createTextNode('seek test'));
    seekBtn.addEventListener('click', () => {
      audio.fastSeek(1);
    });
    container1.appendChild(seekBtn);
    await matchScreenshot();
  });
});
