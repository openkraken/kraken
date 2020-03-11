it('position', () => {
  function setStyle(dom, object) {
    for (const key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const WIDTH = '100vw';
  const HEIGHT = '100vh';

  const container = document.createElement('div');
  setStyle(container, {
    backgroundColor: '#252423',
    width: WIDTH,
    height: HEIGHT
  });

  const absoluteEl = document.createElement('p');
  const fixedEl = document.createElement('span');

  const absoluteStyle = {
    position: 'absolute',
    left: '100px',
    top: '100px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'green',
    width: '200px',
    height: '200px'
  };
  const fixedStyle = {
    position: 'fixed',
    left: '200px',
    top: '200px',
    display: 'flex',
    width: '200px',
    height: '200px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'red',
  }

  setStyle(absoluteEl, absoluteStyle);
  setStyle(fixedEl, fixedStyle);

  var textNode1 = document.createTextNode('absolute');
  var textNode2 = document.createTextNode('fixed');
  absoluteEl.appendChild(textNode1);
  fixedEl.appendChild(textNode2);
  container.appendChild(fixedEl);
  container.appendChild(absoluteEl);

  document.body.appendChild(container);
});