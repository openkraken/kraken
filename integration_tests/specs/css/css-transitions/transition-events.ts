describe('Transition events', () => {
  it('basic transitionrun', (done) => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    container1.addEventListener('transitionrun', function self() {
      container1.removeEventListener('transitionstart', self);
      document.body.removeChild(container1);
      done();
    });
    setElementStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform',
      transitionDuration: '1s',
      transitionTimingFunction: 'linear',
    });

    requestAnimationFrame(() => {
      container1.style.transform = 'translate(10px, 10px)';
    });
  });

  it('basic transitionstart', (done) => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    container1.addEventListener('transitionstart', function self() {
      container1.removeEventListener('transitionstart', self);
      document.body.removeChild(container1);
      done();
    });

    setElementStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transition: 'transform 1s linear',
    });

    requestAnimationFrame(() => {
      setElementStyle(container1, {
        transform: 'translate(10px,20px)',
      });
    });
  });

  it('basic transitionend', (done) => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transition: 'transform 1s linear',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    container1.addEventListener('transitionend', async function self() {
      container1.removeEventListener('transitionend', self);
      await snapshot();
      done();
    });
    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'translate(10px,20px)',
      });
    });
  });

  it('mutiple transitionend', (done) => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transition: 'transform 1s linear',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    function first() {
      container1.removeEventListener('transitionend', first);
      sleep(0.1)
        .then(() => {
          container1.addEventListener('transitionend', second);
          setElementStyle(container1, {
            transform: 'translate(250px,250px)',
          });
        });
    }

    function second() {
      container1.removeEventListener('transitionend', second);
      snapshot().then(done);
    }

    container1.addEventListener('transitionend', first);
    requestAnimationFrame(async () => {
      await snapshot();
      setElementStyle(container1, {
        transform: 'translate(30px,30px)',
      });
    });
  });
});
