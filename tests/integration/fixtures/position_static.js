it('position_static', () => {
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
    position: 'static',
    top: '100px',
    left: '100px',
  });
  div1.appendChild(document.createTextNode('static element'));

  document.body.appendChild(div1);
});
