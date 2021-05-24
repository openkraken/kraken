describe('Position', () => {
  it('should work with flow', async () => {
    const container1 = createElementWithStyle('div', {
      width: '200px',
      height: '200px',
      backgroundColor: '#999',
      position: 'relative',
    });

    document.body.appendChild(container1);

    const div1 = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'absolute',
      top: '100px',
      right: '-100px',
    });
    div1.appendChild(document.createTextNode('absolute to container 1'));

    container1.appendChild(div1);

    const container2 = createElementWithStyle('div', {
      width: '200px',
      height: '200px',
      backgroundColor: '#666',
    });
    document.body.appendChild(container2);

    const div2 = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
      position: 'absolute',
      top: '20px',
      left: '20px',
    });
    div2.appendChild(document.createTextNode('absolute to root'));

    container2.appendChild(div2);

    await snapshot();
  });

  it('should work with flex', async () => {
    const WIDTH = '360px';
    const HEIGHT = '640px';

    const container = document.createElement('div');
    setElementStyle(container, {
      backgroundColor: '#252423',
      width: WIDTH,
      height: HEIGHT,
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
      height: '200px',
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
    };

    setElementStyle(absoluteEl, absoluteStyle);
    setElementStyle(fixedEl, fixedStyle);

    var textNode1 = document.createTextNode('absolute');
    var textNode2 = document.createTextNode('fixed');
    absoluteEl.appendChild(textNode1);
    fixedEl.appendChild(textNode2);
    container.appendChild(fixedEl);
    container.appendChild(absoluteEl);

    document.body.appendChild(container);
    await snapshot();
  });

  it('property static', async () => {
    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      position: 'static',
      top: '100px',
      left: '100px',
    });
    div1.appendChild(document.createTextNode('static element'));

    document.body.appendChild(div1);

    await snapshot();
  });

  it('proeprty relative', async () => {
    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      position: 'relative',
      top: '50px',
      left: '50px',
    });
    div1.appendChild(document.createTextNode('relative top & left'));
    document.body.appendChild(div1);

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: '#999',
      position: 'relative',
      bottom: '-50px',
      right: '-50px',
    });
    div2.appendChild(document.createTextNode('relative bottom & right'));
    document.body.appendChild(div2);

    await snapshot();
  });

  it('property fixed', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      width: '200px',
      height: '200px',
      backgroundColor: '#999',
      position: 'relative',
      top: '100px',
      left: '100px',
    });
    document.body.appendChild(container1);

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'fixed',
      top: '50px',
      left: '50px',
    });
    div1.appendChild(document.createTextNode('fixed element'));

    container1.appendChild(div1);

    await snapshot();
  });

  xit('peroperty sticky', async () => {
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
