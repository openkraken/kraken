it('box_model_width', () => {
  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const div = document.createElement('div');
  setStyle(div, {
    width: '100px',
    height: '100px',
    backgroundColor: '#666',
  });

  document.body.appendChild(div);

  requestAnimationFrame(() => {
    div.style.width = '200px';
  });
});
