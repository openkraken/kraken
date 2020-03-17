describe('Position', () => {
  it('should work with flow', async () => {
    const container1 = create('div', {
      width: '200px',
      height: '200px',
      backgroundColor: '#999',
      position: 'relative',
    });

    document.body.appendChild(container1);

    const div1 = create('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'absolute',
      top: '100px',
      right: '-100px',
    });
    div1.appendChild(document.createTextNode('absolute to container 1'));

    container1.appendChild(div1);

    const container2 = create('div', {
      width: '200px',
      height: '200px',
      backgroundColor: '#666',
    });
    document.body.appendChild(container2);

    const div2 = create('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
      position: 'absolute',
      top: '20px',
      left: '20px',
    });
    div2.appendChild(document.createTextNode('absolute to root'));

    container2.appendChild(div2);

    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('should work with flex', () => {
    const WIDTH = '100vw';
    const HEIGHT = '100vh';

    const container = document.createElement('div');
    setStyle(container, {
      backgroundColor: '#252423',
      width: WIDTH,
      height: HEIGHT
    });

    const absoluteEl = document.createElement('p');
    const fixedEl = document.createElement('span');

    const absoluteStyle = {
      position: 'absolute',
      left: '100px',
      top: '100px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: 'green',
      width: '200px',
      height: '200px'
    };
    const fixedStyle = {
      position: 'fixed',
      left: '200px',
      top: '200px',
      display: 'flex',
      width: '200px',
      height: '200px',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: 'red',
    }

    setStyle(absoluteEl, absoluteStyle);
    setStyle(fixedEl, fixedStyle);

    var textNode1 = document.createTextNode('absolute');
    var textNode2 = document.createTextNode('fixed');
    absoluteEl.appendChild(textNode1);
    fixedEl.appendChild(textNode2);
    container.appendChild(fixedEl);
    container.appendChild(absoluteEl);

    document.body.appendChild(container);
  });
});
