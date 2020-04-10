describe('Transition transform', () => {
  it('translate', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform',
      transitionDuration: '1s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(async () => {
      await matchScreenshot();
      setStyle(container1, {
        transform: 'translate(10px,20px)',
      });
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('translate3d', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform',
      transitionDuration: '1s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(async () => {
      await matchScreenshot();
      setStyle(container1, {
        transform: 'translate3d(10px, 10px, 20px)',
      });
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('translateX', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform',
      transitionDuration: '1s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(async () => {
      await matchScreenshot();
      setStyle(container1, {
        transform: 'translateX(20px)',
      });
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('translateY', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform',
      transitionDuration: '1s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(async () => {
      await matchScreenshot();
      setStyle(container1, {
        transform: 'translateY(10px)',
      });
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});