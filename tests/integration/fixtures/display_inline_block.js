it('display_inline_block', () => {
  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const container = document.createElement('div');
  setStyle(container, {
    width: '400px',
    height: '200px',
    backgroundColor: '#ddd',
  });
  document.body.appendChild(container);

  const div1 = document.createElement('div');
  setStyle(div1, {
    width: '200px',
    height: '100px',
    display: 'inline-block',
    backgroundColor: '#666',
  });
  div1.appendChild(document.createTextNode('inline-block'));
  container.appendChild(div1);

  const div2 = document.createElement('div');
  setStyle(div2, {
    width: '200px',
    height: '100px',
    display: 'inline-block',
    backgroundColor: 'red',
  });
  div2.appendChild(document.createTextNode('inline-block'));
  container.appendChild(div2);

  const div3 = document.createElement('div');
  setStyle(div3, {
    width: '200px',
    height: '100px',
    display: 'inline-block',
    backgroundColor: 'blue',
  });
  div3.appendChild(document.createTextNode('inline-block'));
  container.appendChild(div3);

  container.appendChild(document.createTextNode('test text'));
});
