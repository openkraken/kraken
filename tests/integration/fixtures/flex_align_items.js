function setStyle(dom, object) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

(function() {
  document.body.appendChild(document.createTextNode('flex-direction: row, '));
  document.body.appendChild(document.createTextNode('align-items: flex-start'));
  const container = document.createElement('div');
  setStyle(container, {
    width: '200px',
    height: '100px',
    display: 'flex',
    backgroundColor: '#666',
    flexDirection: 'row',
    alignItems: 'flex-start',
  });

  document.body.appendChild(container);

  const child1 = document.createElement('div');
  setStyle(child1, {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
  });
  container.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    width: '50px',
    height: '50px',
    backgroundColor: 'red',
  });
  container.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    width: '50px',
    height: '50px',
    backgroundColor: 'green',
  });
  container.appendChild(child3);
}());

(function() {
  document.body.appendChild(document.createTextNode('flex-direction: row, '));
  document.body.appendChild(document.createTextNode('align-items: flex-end'));
  const container = document.createElement('div');
  setStyle(container, {
    width: '200px',
    height: '100px',
    display: 'flex',
    backgroundColor: '#666',
    flexDirection: 'row',
    alignItems: 'flex-end',
  });

  document.body.appendChild(container);

  const child1 = document.createElement('div');
  setStyle(child1, {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
  });
  container.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    width: '50px',
    height: '50px',
    backgroundColor: 'red',
  });
  container.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    width: '50px',
    height: '50px',
    backgroundColor: 'green',
  });
  container.appendChild(child3);
}());

(function() {
  document.body.appendChild(document.createTextNode('flex-direction: row, '));
  document.body.appendChild(document.createTextNode('align-items: center'));
  const container = document.createElement('div');
  setStyle(container, {
    width: '200px',
    height: '100px',
    display: 'flex',
    backgroundColor: '#666',
    flexDirection: 'row',
    alignItems: 'center',
  });

  document.body.appendChild(container);

  const child1 = document.createElement('div');
  setStyle(child1, {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
  });
  container.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    width: '50px',
    height: '50px',
    backgroundColor: 'red',
  });
  container.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    width: '50px',
    height: '50px',
    backgroundColor: 'green',
  });
  container.appendChild(child3);
}());

(function() {
  document.body.appendChild(document.createTextNode('flex-direction: row, '));
  document.body.appendChild(document.createTextNode('align-items: stretch'));
  const container = document.createElement('div');
  setStyle(container, {
    width: '200px',
    height: '100px',
    display: 'flex',
    backgroundColor: '#666',
    flexDirection: 'row',
    alignItems: 'stretch',
  });

  document.body.appendChild(container);

  const child1 = document.createElement('div');
  setStyle(child1, {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
  });
  container.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    width: '50px',
    height: '50px',
    backgroundColor: 'red',
  });
  container.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    width: '50px',
    height: '50px',
    backgroundColor: 'green',
  });
  container.appendChild(child3);
}());

(function() {
  document.body.appendChild(document.createTextNode('flex-direction: column, '));
  document.body.appendChild(document.createTextNode('align-items: flex-start'));
  const container = document.createElement('div');
  setStyle(container, {
    width: '200px',
    height: '200px',
    display: 'flex',
    backgroundColor: '#666',
    flexDirection: 'column',
    alignItems: 'flex-start',
  });

  document.body.appendChild(container);

  const child1 = document.createElement('div');
  setStyle(child1, {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
  });
  container.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    width: '50px',
    height: '50px',
    backgroundColor: 'red',
  });
  container.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    width: '50px',
    height: '50px',
    backgroundColor: 'green',
  });
  container.appendChild(child3);
}());

(function() {
  document.body.appendChild(document.createTextNode('flex-direction: column, '));
  document.body.appendChild(document.createTextNode('align-items: flex-end'));
  const container = document.createElement('div');
  setStyle(container, {
    width: '200px',
    height: '200px',
    display: 'flex',
    backgroundColor: '#666',
    flexDirection: 'column',
    alignItems: 'flex-end',
  });

  document.body.appendChild(container);

  const child1 = document.createElement('div');
  setStyle(child1, {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
  });
  container.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    width: '50px',
    height: '50px',
    backgroundColor: 'red',
  });
  container.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    width: '50px',
    height: '50px',
    backgroundColor: 'green',
  });
  container.appendChild(child3);
}());

(function() {
  document.body.appendChild(document.createTextNode('flex-direction: column, '));
  document.body.appendChild(document.createTextNode('align-items: center'));
  const container = document.createElement('div');
  setStyle(container, {
    width: '200px',
    height: '200px',
    display: 'flex',
    backgroundColor: '#666',
    flexDirection: 'column',
    alignItems: 'center',
  });

  document.body.appendChild(container);

  const child1 = document.createElement('div');
  setStyle(child1, {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
  });
  container.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    width: '50px',
    height: '50px',
    backgroundColor: 'red',
  });
  container.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    width: '50px',
    height: '50px',
    backgroundColor: 'green',
  });
  container.appendChild(child3);
}());

(function() {
  document.body.appendChild(document.createTextNode('flex-direction: column, '));
  document.body.appendChild(document.createTextNode('align-items: stretch'));
  const container = document.createElement('div');
  setStyle(container, {
    width: '200px',
    height: '200px',
    display: 'flex',
    backgroundColor: '#666',
    flexDirection: 'column',
    alignItems: 'stretch',
  });

  document.body.appendChild(container);

  const child1 = document.createElement('div');
  setStyle(child1, {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
  });
  container.appendChild(child1);

  const child2 = document.createElement('div');
  setStyle(child2, {
    width: '50px',
    height: '50px',
    backgroundColor: 'red',
  });
  container.appendChild(child2);

  const child3 = document.createElement('div');
  setStyle(child3, {
    width: '50px',
    height: '50px',
    backgroundColor: 'green',
  });
  container.appendChild(child3);
}());


