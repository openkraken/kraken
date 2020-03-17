describe('flexbox align-items', () => {
  it('should work with flex-start when flex-direction is row', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });

  it('should work with flex-end when flex-direction is row', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });

  it('should work with center when flex-direction is row', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });

  it('should work with stretch when flex-direction is row', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });

  it('should work with flex-start when flex-direction is column', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });

  it('should work with flex-end when flex-direction is column', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });

  it('should work with center when flex-direction is column', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });

  it('should work with stretch when flex-direction is column', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });
});
