(() => {

  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const container1 = document.createElement('div');
  document.body.appendChild(container1);

  const container2 = document.createElement('div');
  container1.appendChild(container2);

  const block1 = document.createElement('div');
  setStyle(block1, {
    display: 'inline-block', width: '360px', backgroundColor: 'red'
  });
  const textNode1 = document.createTextNode('1111111111');
  block1.appendChild(textNode1);

  const block2 = document.createElement('div');
  setStyle(block2, {
    display: 'inline-block', width: '360px', backgroundColor: 'green'
  });
  const textNode2 = document.createTextNode('22222222222');
  block2.appendChild(textNode2);

  const block3 = document.createElement('div');
  setStyle(block3, {
    display: 'inline-block', width: '360px', backgroundColor: 'blue'
  });
  const textNode3 = document.createTextNode('33333333333');
  block3.appendChild(textNode3);

  container2.appendChild(block1);
  container2.appendChild(block2);
  container2.appendChild(block3);

  const container3 = document.createElement('div');
  setStyle(container3, {
    backgroundColor: '#999', height: '200px'
  });

  container1.appendChild(container3);
})();
