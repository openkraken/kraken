function setStyle(dom, object) {
  for (const key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

const container1 = document.createElement('div');
setStyle(container1, {
  display: 'flex',
  flexDirection: 'row',
  flexWrap: 'wrap',
  justifyContent: 'center',
  width: '300rpx',
  height: '1000rpx',
  marginBottom: '10rpx',
  backgroundColor: '#ddd'
});

document.body.appendChild(container1);

const child1 = document.createElement('div');
setStyle(child1, {
  display: 'inline-block',
  backgroundColor: '#f40',
  width: '100rpx',
  height: '100rpx',
  margin: '10rpx'
});
container1.appendChild(child1);

const child2 = document.createElement('div');
setStyle(child2, {
  display: 'inline-block',
  backgroundColor: '#f40',
  width: '100rpx',
  height: '100rpx',
  margin: '10rpx'
});
container1.appendChild(child2);

const child3 = document.createElement('div');
setStyle(child3, {
  display: 'inline-block',
  backgroundColor: '#f40',
  width: '100rpx',
  height: '100rpx',
  margin: '10rpx'
});
container1.appendChild(child3);
