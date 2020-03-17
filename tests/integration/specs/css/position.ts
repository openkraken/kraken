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

  it('property static', async () => {
    const div1 = document.createElement('div');
    setStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      position: 'static',
      top: '100px',
      left: '100px',
    });
    div1.appendChild(document.createTextNode('static element'));

    document.body.appendChild(div1);

    await matchScreenshot();
  });

  it('proeprty relative', async () => {
    const div1 = document.createElement('div');
    setStyle(div1, {
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
    setStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: '#999',
      position: 'relative',
      bottom: '-50px',
      right: '-50px',
    });
    div2.appendChild(document.createTextNode('relative bottom & right'));
    document.body.appendChild(div2);

    await matchScreenshot();
  });

  it('property fixed', async () => {
    const container1 = document.createElement('div');
    setStyle(container1, {
      width: '200px',
      height: '200px',
      backgroundColor: '#999',
      position: 'relative',
      top: '100px',
      left: '100px',
    });
    document.body.appendChild(container1);

    const div1 = document.createElement('div');
    setStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'fixed',
      top: '50px',
      left: '50px',
    });
    div1.appendChild(document.createTextNode('fixed element'));

    container1.appendChild(div1);

    await matchScreenshot();
  });

  it('peroperty sticky', async () => {
    const sticky1 = document.createElement('div');
    sticky1.appendChild(document.createTextNode('sticky top 1'));
    setStyle(sticky1, {
      backgroundColor: '#f40',
      color: '#FFF',
      position: 'sticky',
      top: '0px',
      width: '414px',
      height: '50px',
    });

    const block1 = document.createElement('div');
    block1.appendChild(document.createTextNode('block1'));
    setStyle(block1, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky2 = document.createElement('div');
    sticky2.appendChild(document.createTextNode('sticky top 2'));
    setStyle(sticky2, {
      backgroundColor: 'blue',
      color: '#FFF',
      position: 'sticky',
      top: '50px',
      width: '414px',
      height: '50px',
    });

    const block2 = document.createElement('div');
    block2.appendChild(document.createTextNode('block2'));
    setStyle(block2, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky3 = document.createElement('div');
    sticky3.appendChild(document.createTextNode('sticky top 3'));
    setStyle(sticky3, {
      backgroundColor: 'green',
      color: '#FFF',
      position: 'sticky',
      top: '100px',
      width: '414px',
      height: '50px',
    });

    const block3 = document.createElement('div');
    block3.appendChild(document.createTextNode('block3'));
    setStyle(block3, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky4 = document.createElement('div');
    sticky4.appendChild(document.createTextNode('sticky bottom'));
    setStyle(sticky4, {
      backgroundColor: 'purple',
      color: '#FFF',
      position: 'sticky',
      bottom: '50px',
      width: '414px',
      height: '50px',
    });

    const block4 = document.createElement('div');
    block4.appendChild(document.createTextNode('bottom block'));
    setStyle(block4, {
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

    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('change from non-static to static', async done => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '400px',
      height: '400px',
      marginBottom: '20px',
      backgroundColor: '#999',
      position: 'relative',
    });
    document.body.appendChild(container);

    const div1 = document.createElement('div');
    setStyle(div1, {
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
    setStyle(div2, {
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
    setStyle(div3, {
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
    setStyle(div4, {
      width: '100px',
      height: '100px',
      backgroundColor: 'yellow',
      position: 'sticky',
      top: '50px',
    });
    div4.appendChild(document.createTextNode('sticky to static'));
    container.appendChild(div4);

    await matchScreenshot();

    requestAnimationFrame(async () => {
      div1.style.position = 'static';
      div2.style.position = 'static';
      div3.style.position = 'static';
      div4.style.position = 'static';

      await matchScreenshot();
      done();
    });
  });

  it('change from static to non-static', async done => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '400px',
      height: '400px',
      marginBottom: '20px',
      backgroundColor: '#999',
      position: 'relative',
    });
    document.body.appendChild(container);

    const div1 = document.createElement('div');
    setStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      top: '200px',
      left: '100px',
    });
    div1.appendChild(document.createTextNode('absolute to static'));
    container.appendChild(div1);

    const div2 = document.createElement('div');
    setStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
      top: '50px',
      left: '100px',
    });
    div2.appendChild(document.createTextNode('relative to static'));
    container.appendChild(div2);

    const div3 = document.createElement('div');
    setStyle(div3, {
      width: '100px',
      height: '100px',
      backgroundColor: 'green',
      top: '200px',
      left: '200px',
    });
    div3.appendChild(document.createTextNode('fixed to static'));
    container.appendChild(div3);

    const div4 = document.createElement('div');
    setStyle(div4, {
      width: '100px',
      height: '100px',
      backgroundColor: 'yellow',
      top: '50px',
    });
    div4.appendChild(document.createTextNode('sticky to static'));
    container.appendChild(div4);

    await matchScreenshot();

    requestAnimationFrame(async () => {
      div1.style.position = 'absolute';
      div2.style.position = 'relative';
      div3.style.position = 'fixed';
      div4.style.position = 'sticky';

      await matchScreenshot();
      done();
    });
  });
});
