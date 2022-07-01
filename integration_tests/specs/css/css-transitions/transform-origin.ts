describe('Transition transform origin', () => {
  it('length', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
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

    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });

    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transformOrigin: '10px 10px',
        transform: 'rotateZ(0.6turn)',
      });
    });
  });

  it('percent', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
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

    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });

    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transformOrigin: '80% 80%',
        transform: 'rotateZ(0.6turn)',
      });
    });
  });
});

describe('Transition transform', () => {
  it('keyword', done => {
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
        transform: 'rotateZ(0.1turn)',
        transformOrigin: 'top left',
      });
    });
  });
});
