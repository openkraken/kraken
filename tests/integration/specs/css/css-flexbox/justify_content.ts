describe('flexbox justify-content', () => {
  it('should work with flex-start when flex-direction is row', async () => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      justifyContent: 'flex-start',
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
      justifyContent: 'flex-end',
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
      justifyContent: 'center',
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

  it('should work with space-around when flex-direction is row', async () => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      justifyContent: 'space-around',
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

  it('should work with space-between when flex-direction is row', async () => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      justifyContent: 'space-between',
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
      justifyContent: 'flex-start',
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
      justifyContent: 'flex-end',
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
      justifyContent: 'center',
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

  it('should work with space-around when flex-direction is column', async () => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      justifyContent: 'space-around',
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

  it('should work with space-between when flex-direction is column', async () => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      justifyContent: 'space-between',
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
