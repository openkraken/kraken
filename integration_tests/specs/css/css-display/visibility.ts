describe('Visibility', () => {
  it('should turn to hidden', async () => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);

    setElementStyle(container1, {
      backgroundColor: '#f40',
      width: '200px',
      height: '200px',
    });

    await snapshot();

    const container2 = document.createElement('div');
    container2.appendChild(document.createTextNode('visibility test'));
    setElementStyle(container2, {
      backgroundColor: '#999',
      width: '100px',
      height: '100px',
    });

    container1.appendChild(container2);

    await snapshot();

    container1.addEventListener('click', () => {
      console.log('container clicked');
    });
    container2.addEventListener('click', () => {
      console.log('inner clicked');
    });

    setElementStyle(container2, {
      visibility: 'hidden',
    });

    await snapshot();
  });
});
