describe('Transition transform', () => {
  it('rotateZ', done => {
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
        transform: 'rotateZ(0.6turn)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('rotate3d', done => {
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
        transform: 'rotate3d(10, 10, 10, 0.6turn)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('rotateX', done => {
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
        transform: 'rotateX(0.6turn)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('rotateY', done => {
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
        transform: 'rotateY(0.6turn)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});
