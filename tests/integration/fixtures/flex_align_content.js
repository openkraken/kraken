it('flex_align_content', () => {
  function setStyle(dom, object) {
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  (function() {
    document.body.appendChild(document.createTextNode('flex-direction: row, '));
    document.body.appendChild(document.createTextNode('align-content: start'));
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '300px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      flexWrap: 'wrap',
      alignContent: 'start',
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

    const child4 = document.createElement('div');
    setStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
  }());

  (function() {
    document.body.appendChild(document.createTextNode('flex-direction: row, '));
    document.body.appendChild(document.createTextNode('align-content: end'));
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '300px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      flexWrap: 'wrap',
      alignContent: 'end',
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

    const child4 = document.createElement('div');
    setStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
  }());

  (function() {
    document.body.appendChild(document.createTextNode('flex-direction: row, '));
    document.body.appendChild(document.createTextNode('align-content: center'));
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '300px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      flexWrap: 'wrap',
      alignContent: 'center',
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

    const child4 = document.createElement('div');
    setStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
  }());

  (function() {
    document.body.appendChild(document.createTextNode('flex-direction: row, '));
    document.body.appendChild(document.createTextNode('align-content: space-around'));
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '300px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      flexWrap: 'wrap',
      alignContent: 'space-around',
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

    const child4 = document.createElement('div');
    setStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
  }());

  (function() {
    document.body.appendChild(document.createTextNode('flex-direction: row, '));
    document.body.appendChild(document.createTextNode('align-content: space-between'));
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '300px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      flexWrap: 'wrap',
      alignContent: 'space-between',
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

    const child4 = document.createElement('div');
    setStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
  }());

  (function() {
    document.body.appendChild(document.createTextNode('flex-direction: row, '));
    document.body.appendChild(document.createTextNode('align-content: space-evenly'));
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '300px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      flexWrap: 'wrap',
      alignContent: 'space-evenly',
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

    const child4 = document.createElement('div');
    setStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
  }());
});
