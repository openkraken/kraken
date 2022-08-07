describe('Transition transform', () => {
  it('matrix', done => {
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
        transform: 'matrix(0,1,1,1,10,10)',
      });
    });
  });
});

describe('Transition transform', () => {
  it('matrix3d', done => {
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
        transform: 'matrix3d(0,1,1,1,10,10,1,0,0,1,1,1,1,1,0)',
      });
    });
  });
});
