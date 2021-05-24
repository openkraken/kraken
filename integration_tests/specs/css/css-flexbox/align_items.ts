describe('flexbox align-items', () => {
  it('should work with flex-start when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      alignItems: 'flex-start',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with flex-end when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      alignItems: 'flex-end',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with center when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      alignItems: 'center',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);
    child1.appendChild(document.createTextNode('block with no height'));

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with stretch when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      alignItems: 'stretch',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);
    child1.appendChild(document.createTextNode('block with no height'));

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with baseline when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      alignItems: 'baseline',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
      fontSize: '26px',
    });
    const text1 = document.createTextNode('111');
    child1.appendChild(text1);
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
      fontSize: '14px',

    });
    const text2 = document.createTextNode('222');
    child2.appendChild(text2);
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    fontSize: '20px',

    });
    const text3 = document.createTextNode('333');
    child3.appendChild(text3);
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with flex-start when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      alignItems: 'flex-start',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with flex-end when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      alignItems: 'flex-end',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with center when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      alignItems: 'center',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);
    child1.appendChild(document.createTextNode('block with no width'));

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with stretch when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      alignItems: 'stretch',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);
    child1.appendChild(document.createTextNode('block with no width'));

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });
});
