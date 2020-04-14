describe('Transition transform origin', () => {
  it('length', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform-origin',
      transitionDuration: '1s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(async () => {
      await matchScreenshot();
      setStyle(container1, {
        transform: 'rotateZ(0.6turn)',
        transformOrigin: '10px 10px',
      });
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform origin', () => {
  it('percent', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform-origin',
      transitionDuration: '1s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(async () => {
      await matchScreenshot();
      setStyle(container1, {
        transform: 'rotateZ(0.6turn)',
        transformOrigin: '80% 80%',
      });
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform origin', () => {
  it('keyword', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform-origin',
      transitionDuration: '1s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(async () => {
      await matchScreenshot();
      setStyle(container1, {
        transform: 'rotateZ(0.1turn)',
        transformOrigin: 'top left',
      });
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});