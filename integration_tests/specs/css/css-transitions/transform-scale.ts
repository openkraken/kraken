describe('Transition transform', () => {
  it('scale', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
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

    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });
    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'scale(2,2)',
      });
    });
  });
});

describe('Transition transform', () => {
  it('scale3d', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
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

    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });
    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'scale3d(2, 2, 2)',
      });
    });
  });
});

describe('Transition transform', () => {
  it('scaleX', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
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

    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });
    requestAnimationFrame(async () => {
          await snapshot();
      setElementStyle(container1, {
        transform: 'scaleX(2)',
      });
    });
  });
});

describe('Transition transform', () => {
  it('scaleY', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
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

    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });
    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'scaleY(2)',
      });
    });
  });
});
