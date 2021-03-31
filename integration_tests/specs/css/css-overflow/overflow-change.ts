/*auto generated*/
describe('overflow-change', () => {
  it('should work with overflow change from visible to hidden', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '40px',
        }
      },
      [
        createText(`hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world`)
      ]
    );
    append(BODY, cont);

    setTimeout(async() => {
      cont.style.overflow = 'hidden';
      await matchViewportSnapshot(0.1);
      done();
    }, 100);

    await matchViewportSnapshot();
  });

  it('should work with overflow change from hidden to visible', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '40px',
          overflow: 'hidden',
        }
      },
      [
        createText(`hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world`)
      ]
    );
    append(BODY, cont);

    setTimeout(async() => {
      cont.style.overflow = 'visible';
      await matchViewportSnapshot(0.1);
      done();
    }, 100);

    await matchViewportSnapshot();
  });

  it('change from scroll to visible and no transform exists', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
          overflow: 'scroll',
        }
      },
      [
        createText(`00000 11111 22222 33333 444444 55555 66666 77777 88888 99999`)
      ]
    );
    append(BODY, cont);

    await matchViewportSnapshot();

    requestAnimationFrame(async() => {
      cont.style.overflow = 'visible';
      await matchViewportSnapshot(0.1);
      done();
    });
  });

  it('change from scroll to visible and transform exists', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          backgroundColor: 'green',
          transform: 'translate(100px, 0)',
          fontSize: '18px',
          overflow: 'scroll',
        }
      },
      [
        createText(`00000 11111 22222 33333 444444 55555 66666 77777 88888 99999`)
      ]
    );
    append(BODY, cont);

    await matchViewportSnapshot();

    requestAnimationFrame(async() => {
      cont.style.overflow = 'visible';
      await matchViewportSnapshot(0.1);
      done();
    });
  });

  it('change from visible to scroll and transform exists', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
          transform: 'translate(100px, 0)',
        }
      },
      [
        createText(`00000 11111 22222 33333 444444 55555 66666 77777 88888 99999`)
      ]
    );
    append(BODY, cont);

    await matchViewportSnapshot();

    requestAnimationFrame(async() => {
      cont.style.overflow = 'scroll';
      await matchViewportSnapshot(0.1);
      done();
    });
  });

  it('apply scroll and position style multiple times', async (done) => {
    let inner3 = createElement('div', {
      style: {
        "display": "flex",
        "position": "relative",
        "overflowY": "scroll",
        width: '100px',
        height: '100px',
        backgroundColor: 'green',
        fontSize: '18px',
      }
    }, [
      (inner2 = createElement('div', {
        style: {
          "position": "relative"
        }
      }, [
        createText(`00000 11111 22222 33333 444444 55555 66666 77777 88888 99999`)

      ]))
    ]);
    BODY.appendChild(inner3);

    await matchViewportSnapshot();

    requestAnimationFrame(async() => {
      inner3.style.position = 'static';
      inner3.style.position = 'relative';
      inner3.style.overflowY = 'visible';
      inner3.style.overflowY = 'scroll';
      await matchViewportSnapshot(0.1);
      done();
    });
  });
});
