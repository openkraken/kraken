describe('visibility', () => {
  it('should turn to hidden', async () => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);

    setStyle(container1, {
      backgroundColor: '#f40',
      width: '200px',
      height: '200px',
    });

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot();

    const container2 = document.createElement('div');
    container2.appendChild(document.createTextNode('visibility test'));
    setStyle(container2, {
      backgroundColor: '#999',
      width: '100px',
      height: '100px',
    });

    container1.appendChild(container2);

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot();

    container1.addEventListener('click', () => {
      console.log('container clicked');
    });
    container2.addEventListener('click', () => {
      console.log('inner clicked');
    });

    setStyle(container2, {
      visibility: 'hidden',
    });

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot();
  });
});
