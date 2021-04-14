describe('Transition transform', () => {
  it('skew', done => {
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

    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'skew(0.3turn,0.6turn)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('skewX', done => {
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

    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'skewX(0.3turn)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('skewY', done => {
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

    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'skewY(0.3turn)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});
