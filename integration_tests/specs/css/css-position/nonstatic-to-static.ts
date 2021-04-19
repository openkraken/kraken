describe('Position non-static', () => {
  it('to static', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '400px',
      height: '400px',
      marginBottom: '20px',
      backgroundColor: '#999',
      position: 'relative',
    });
    document.body.appendChild(container);

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'absolute',
      top: '100px',
      left: '100px',
    });
    div1.appendChild(document.createTextNode('absolute to static'));
    container.appendChild(div1);

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
      position: 'relative',
      top: '50px',
      left: '100px',
    });
    div2.appendChild(document.createTextNode('relative to static'));
    container.appendChild(div2);

    const div3 = document.createElement('div');
    setElementStyle(div3, {
      width: '100px',
      height: '100px',
      backgroundColor: 'green',
      position: 'fixed',
      top: '200px',
      left: '200px',
    });
    div3.appendChild(document.createTextNode('fixed to static'));
    container.appendChild(div3);

    const div4 = document.createElement('div');
    setElementStyle(div4, {
      width: '100px',
      height: '100px',
      backgroundColor: 'yellow',
      position: 'sticky',
      top: '50px',
    });
    div4.appendChild(document.createTextNode('sticky to static'));
    container.appendChild(div4);

    await snapshot();

    div1.style.position = 'static';
    div2.style.position = 'static';
    div3.style.position = 'static';
    div4.style.position = 'static';

    await snapshot();
  });
});
