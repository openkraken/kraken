describe('Position static', () => {
  it('to non-static', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '400px',
      height: '400px',
      backgroundColor: '#999',
      position: 'relative',
    });
    document.body.appendChild(container);

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      top: '200px',
      left: '100px',
    });
    div1.appendChild(document.createTextNode('static to absolute'));
    container.appendChild(div1);

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
      top: '50px',
      left: '100px',
    });
    div2.appendChild(document.createTextNode('static to relative'));
    container.appendChild(div2);

    const div3 = document.createElement('div');
    setElementStyle(div3, {
      width: '100px',
      height: '100px',
      backgroundColor: 'green',
      top: '200px',
      left: '200px',
    });
    div3.appendChild(document.createTextNode('static to fixed'));
    container.appendChild(div3);

    const div4 = document.createElement('div');
    setElementStyle(div4, {
      width: '100px',
      height: '100px',
      backgroundColor: 'yellow',
      top: '50px',
    });
    div4.appendChild(document.createTextNode('static to sticky'));
    container.appendChild(div4);

    div1.style.position = 'absolute';
    div2.style.position = 'relative';
    div3.style.position = 'fixed';
    div4.style.position = 'sticky';

    await snapshot();
  });
});
