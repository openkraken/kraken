describe('Transition transform', () => {
  it('001', done => {
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

    requestAnimationFrame(() => {
      setStyle(container1, {
        transform: 'translate3d(200px, 0, 0)',
      });

      // Wait for animation finished.
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('rotateZ', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform',
      transitionDuration: '2s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(() => {
      setStyle(container1, {
        transform: 'rotateZ(1turn)',
      });


      var count = 0;
      // Wait for animation finished.
      var id = setInterval(async () => {
        await matchScreenshot();
        if (++count > 4) {
            clearInterval(id);
            done();
        }
      }, 250);
    });
  });
});
