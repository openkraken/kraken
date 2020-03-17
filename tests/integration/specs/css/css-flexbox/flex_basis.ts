describe('flexbox flex-basis', () => {
  it('should work with auto', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });

  it('should work with width', async () => {
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

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });
});
