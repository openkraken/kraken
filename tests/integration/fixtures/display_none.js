it('displayNone', () => {
  function setStyle(dom, object) {
    for (const key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const container1 = document.createElement('div');
  document.body.appendChild(container1);
  container1.appendChild(document.createTextNode('block text'));

  setStyle(container1, {
    display: 'block', width: '360rpx', height: '200rpx', backgroundColor: 'blue'
  });
  setStyle(container1, {
    display: 'none'
  });

  const container2 = document.createElement('div');
  document.body.appendChild(container2);
  container2.appendChild(document.createTextNode('flex child 1'));
  container2.appendChild(document.createTextNode('flex child 2'));
  setStyle(container2, {
    display: 'none', width: '360rpx', height: '200rpx', backgroundColor: 'red',
    flexDirection: 'row', justifyContent: 'center',
  });

  setStyle(container2, {
    display: 'block'
  });
});