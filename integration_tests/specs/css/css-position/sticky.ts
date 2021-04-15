describe('Position sticky', () => {
  it('001', async () => {
    const sticky1 = document.createElement('div');
    sticky1.appendChild(document.createTextNode('sticky top 1'));
    setElementStyle(sticky1, {
      backgroundColor: '#f40',
      color: '#FFF',
      position: 'sticky',
      top: '0px',
      width: '414px',
      height: '50px',
    });

    const block1 = document.createElement('div');
    block1.appendChild(document.createTextNode('block1'));
    setElementStyle(block1, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky2 = document.createElement('div');
    sticky2.appendChild(document.createTextNode('sticky top 2'));
    setElementStyle(sticky2, {
      backgroundColor: 'blue',
      color: '#FFF',
      position: 'sticky',
      top: '50px',
      width: '414px',
      height: '50px',
    });

    const block2 = document.createElement('div');
    block2.appendChild(document.createTextNode('block2'));
    setElementStyle(block2, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky3 = document.createElement('div');
    sticky3.appendChild(document.createTextNode('sticky top 3'));
    setElementStyle(sticky3, {
      backgroundColor: 'green',
      color: '#FFF',
      position: 'sticky',
      top: '100px',
      width: '414px',
      height: '50px',
    });

    const block3 = document.createElement('div');
    block3.appendChild(document.createTextNode('block3'));
    setElementStyle(block3, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky4 = document.createElement('div');
    sticky4.appendChild(document.createTextNode('sticky bottom'));
    setElementStyle(sticky4, {
      backgroundColor: 'purple',
      color: '#FFF',
      position: 'sticky',
      bottom: '50px',
      width: '414px',
      height: '50px',
    });

    const block4 = document.createElement('div');
    block4.appendChild(document.createTextNode('bottom block'));
    setElementStyle(block4, {
      backgroundColor: '#999',
      height: '800px',
    });

    document.body.appendChild(sticky1);
    document.body.appendChild(block1);
    document.body.appendChild(sticky2);
    document.body.appendChild(block2);
    document.body.appendChild(sticky3);
    document.body.appendChild(block3);
    document.body.appendChild(sticky4);
    document.body.appendChild(block4);

    await snapshot();
  });
});
