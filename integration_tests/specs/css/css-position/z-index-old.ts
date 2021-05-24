describe('ZIndex', () => {
  it('basic', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      width: '200px',
      height: '200px',
      backgroundColor: '#999',
      position: 'relative',
    });
    document.body.appendChild(container1);

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'absolute',
      top: '50px',
      left: '50px',
      zIndex: 2,
    });
    div1.appendChild(document.createTextNode('z-index 2'));

    container1.appendChild(div1);

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: 'green',
      position: 'absolute',
      top: '100px',
      left: '100px',
      zIndex: 1,
    });
    div2.appendChild(document.createTextNode('z-index 1'));

    container1.appendChild(div2);

    await snapshot();
  });
});
