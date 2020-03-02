function setStyle(dom, object) {
  for (const key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}
function setAttribute(dom, object) {
  for (const key in object) {
    if (object.hasOwnProperty(key)) {
      dom.setAttribute(key, object[key]);
    }
  }
}

const container1 = document.createElement('div');
setStyle(container1, {
  height: '500rpx',
});

document.body.appendChild(container1);

const video = document.createElement('video');
setStyle(video, {
  width: '750rpx',
  height: '400rpx'
});
setAttribute(video, {
  autoPlay: true,
  src: 'https://videocdn.taobao.com/oss/ali-video/1fa0c3345eb3433b8af7e995e2013cea/1458900536/video.mp4'
});

container1.appendChild(video);

const pauseBtn = document.createElement('div');
pauseBtn.appendChild(document.createTextNode('pause button'));
pauseBtn.addEventListener('click', () => {
  console.log('video pause');
  video.pause();
});
container1.appendChild(pauseBtn);

const playBtn = document.createElement('div');
playBtn.appendChild(document.createTextNode('playBtn button'));
playBtn.addEventListener('click', () => {
  console.log('video play');
  video.play();
});
container1.appendChild(playBtn);
