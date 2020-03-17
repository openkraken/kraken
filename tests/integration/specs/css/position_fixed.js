it('position_fixed', () => {
  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const container1 = document.createElement('div');
  setStyle(container1, {
    width: '200px',
    height: '200px',
    backgroundColor: '#999',
    position: 'relative',
    top: '100px',
    left: '100px',
  });
  document.body.appendChild(container1);

  const div1 = document.createElement('div');
  setStyle(div1, {
    width: '100px',
    height: '100px',
    backgroundColor: 'red',
    position: 'fixed',
    top: '50px',
    left: '50px',
  });
  div1.appendChild(document.createTextNode('fixed element'));

  container1.appendChild(div1);
});
