describe('Transition transform', () => {
  it('translate', done => {
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
        transform: 'translate(10px,20px)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('translate3d', done => {
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
        transform: 'translate3d(10px, 10px, 20px)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});

describe('Transition transform', () => {
  it('translateX',  async () => {
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
        transform: 'translateX(20px)',
      });
    });

    await snapshot(1.1);
  });
});

describe('Transition transform', () => {
  it('translateY', done => {
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
        transform: 'translateY(10px)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });
});

describe('Multiple transition transform', () => {
  it('translate3d', done => {
    const container1 = document.createElement('div');
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '200px',
      height: '200px',
      backgroundColor: 'red',
    });
    document.body.appendChild(div);

    setElementStyle(container1, {
      width: '100px',
      height: '100px',
      padding: '20px',
      marginLeft: '100px',
      backgroundColor: '#999',
      transitionProperty: 'transform',
      transitionDuration: '0.5s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    div.appendChild(container1);

    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'translate3d(-100px, 0vw, 0vw)',
      });
      setElementStyle(container1, {
        transform: 'translate3d(-100px, 0px, 0px)',
      });
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1000);
    });
  });
});
