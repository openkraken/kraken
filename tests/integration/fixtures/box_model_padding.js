it('box_model_padding', () => {
  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const container1 = document.createElement('div');
  setStyle(container1, {
    width: '100px',
    height: '100px',
    backgroundColor: '#666',
    padding: 0
  });

  document.body.appendChild(container1);

  const container2 = document.createElement('div');
  setStyle(container2, {
    width: '50px',
    height: '50px',
    backgroundColor: '#f40',
  });

  container1.appendChild(container2);

  requestAnimationFrame(() => {
    container1.style.padding = '20px';
  });
});
