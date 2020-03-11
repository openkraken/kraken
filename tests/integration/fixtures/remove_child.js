it('removeChild', () => {
  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  const block1 = document.createElement('p');
  block1.appendChild(document.createTextNode('text 1'));
  setStyle(block1, {
    backgroundColor: '#999', textAlign: "center",
  });

  const block2 = document.createElement('div');
  block2.appendChild(document.createTextNode('text 2'));
  setStyle(block2, {
    backgroundColor: '#f40', textAlign: "center",
  });

  document.body.appendChild(block1);
  document.body.appendChild(block2);
  document.body.removeChild(block1);
});