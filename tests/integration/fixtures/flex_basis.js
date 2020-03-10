function setStyle(dom, object) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

(function() {
  document.body.appendChild(document.createTextNode('flex-basis: auto'));

  const container1 = document.createElement('div');
  setStyle(container1, {
    display: 'flex',
    flexDirection: 'row',
    width: '300px',
    height: '100px',
    backgroundColor: '#999',
    justifyContent: 'center'
  });

  document.body.appendChild(container1);

  const child1 = document.createElement('div');
  setStyle(child1, {
    backgroundColor: '#333',
  });
  child1.appendChild(document.createTextNode('Item One'));
  container1.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    backgroundColor: '#f40'
  });
  child2.appendChild(document.createTextNode('Item Two'));
  container1.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    backgroundColor: 'green'
  });
  child3.appendChild(document.createTextNode('Item Three'));
  container1.appendChild(child3);
}());


(function() {
  document.body.appendChild(document.createTextNode('flex-basis: 100px'));

  const container1 = document.createElement('div');
  setStyle(container1, {
    display: 'flex',
    flexDirection: 'row',
    width: '300px',
    height: '100px',
    backgroundColor: '#999',
    justifyContent: 'center'
  });

  document.body.appendChild(container1);

  const child1 = document.createElement('div');
  setStyle(child1, {
    backgroundColor: '#333',
    flexBasis: '100px',
  });
  child1.appendChild(document.createTextNode('Item One'));
  container1.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    backgroundColor: '#f40'
  });
  child2.appendChild(document.createTextNode('Item Two'));
  container1.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    backgroundColor: 'green'
  });
  child3.appendChild(document.createTextNode('Item Three'));
  container1.appendChild(child3);
}());
