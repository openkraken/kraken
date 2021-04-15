describe('flexbox flex-direction', () => {
  it('should work with row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
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
    await snapshot();
  });

  it('should work with column', async () => {
    const container2 = document.createElement('div');
    setElementStyle(container2, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
    });

    document.body.appendChild(container2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container2.appendChild(child3);

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container2.appendChild(child4);
    await snapshot();
  });
});
