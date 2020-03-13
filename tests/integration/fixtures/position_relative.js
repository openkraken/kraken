it('position_relative', () => {
  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const div1 = document.createElement('div');
  setStyle(div1, {
    width: '100px',
    height: '100px',
    backgroundColor: '#666',
    position: 'relative',
    top: '50px',
    left: '50px',
  });
  div1.appendChild(document.createTextNode('relative top & left'));
  document.body.appendChild(div1);

  const div2 = document.createElement('div');
  setStyle(div2, {
    width: '100px',
    height: '100px',
    backgroundColor: '#999',
    position: 'relative',
    bottom: '-50px',
    right: '-50px',
  });
  div2.appendChild(document.createTextNode('relative bottom & right'));
  document.body.appendChild(div2);
});
