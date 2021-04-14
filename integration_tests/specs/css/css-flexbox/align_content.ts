describe('flexbox align-content', () => {
  it('should work with start when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
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

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);

    await snapshot();
  });

  it('should work with end when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
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

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
    await snapshot();
  });

  it('should work with center when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
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

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
    await snapshot();
  });

  it('should work with space-around when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
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

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
    await snapshot();
  });

  it('should work with space-between when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
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

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
    await snapshot();
  });

  it('should work with space-evenly when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
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

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'yellow',
    });
    container.appendChild(child4);
    await snapshot();
  });
});
