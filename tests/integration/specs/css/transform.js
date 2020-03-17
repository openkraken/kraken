it('transform', () => {
  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const div1 = document.createElement('div');
  document.body.appendChild(div1);
  setStyle(div1, {
    width: '100px',
    height: '100px',
    backgroundColor: 'red',
    transform: 'translate(10px, 6px )',
  });

  const div2 = document.createElement('div');
  document.body.appendChild(div2);
  setStyle(div2, {
    width: '100px',
    height: '100px',
    marginTop: '10px',
    backgroundColor: 'red',
    transform: 'scale(0.6, 0.8)',
  });

  const div3 = document.createElement('div');
  document.body.appendChild(div3);
  setStyle(div3, {
    width: '100px',
    height: '100px',
    marginTop: '10px',
    backgroundColor: 'red',
    transform: 'skew(-5deg)',
  });

  const div4 = document.createElement('div');
  document.body.appendChild(div4);
  setStyle(div4, {
    width: '100px',
    height: '100px',
    backgroundColor: 'red',
    transform: 'matrix(0,1,1,1,10,10)',
  });

  const div7 = document.createElement('div');
  document.body.appendChild(div7);
  setStyle(div7, {
    width: '100px',
    height: '100px',
    backgroundColor: 'red',
    transform: 'rotate(5deg)',
  });

  const div5 = document.createElement('div');
  document.body.appendChild(div5);
  setStyle(div5, {
    width: '100px',
    height: '100px',
    marginTop: '10px',
    backgroundColor: 'red',
    transform: 'matrix3d(0,1,1,1,10,10,1,0,0,1,1,1,1,1,0)',
  });

  const div6 = document.createElement('div');
  document.body.appendChild(div6);
  setStyle(div6, {
    width: '100px',
    height: '100px',
    marginTop: '10px',
    backgroundColor: 'red',
    transform: 'scale3d(0.6, 0.8, 0.3) rotate3d(5deg, 8deg, 3deg)',
  });
});