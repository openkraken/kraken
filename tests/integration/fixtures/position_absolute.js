it('position', () => {
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
  });
  document.body.appendChild(container1);

  const div1 = document.createElement('div');
  setStyle(div1, {
    width: '100px',
    height: '100px',
    backgroundColor: 'red',
    position: 'absolute',
    top: '100px',
    right: '-100px',
  });
  div1.appendChild(document.createTextNode('absolute to container 1'));

  container1.appendChild(div1);

  const container2 = document.createElement('div');
  setStyle(container2, {
    width: '200px',
    height: '200px',
    backgroundColor: '#666',
  });
  document.body.appendChild(container2);

  const div2 = document.createElement('div');
  setStyle(div2, {
    width: '100px',
    height: '100px',
    backgroundColor: 'blue',
    position: 'absolute',
    top: '20px',
    left: '20px',
  });
  div2.appendChild(document.createTextNode('absolute to root'));

  container2.appendChild(div2);
});
