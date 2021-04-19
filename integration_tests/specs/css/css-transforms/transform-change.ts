describe('transform change', () => {
  it('from not none to none and overflow is visible', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
          transform: 'translate(100px, 0)'
        }
      },
      [
        createText(`00000 11111 22222 33333 444444 55555 66666 77777 88888 99999`)
      ]
    );
    append(BODY, cont);

    await snapshot();

    requestAnimationFrame(async () => {
      cont.style.transform = 'none';
      await snapshot(0.1);
      done();
    });
  });

  it('from not none to none and overflow is scroll', async (done) => {
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
          overflow: 'scroll'
        }
      },
      [
        createText(`00000 11111 22222 33333 444444 55555 66666 77777 88888 99999`)
      ]
    );
    append(BODY, cont);

    await snapshot();

    requestAnimationFrame(async () => {
      cont.style.transform = 'none';
      await snapshot(0.1);
      done();
    });
  });

  it('from none to not none and overflow is visible', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
          transform: 'none',
        }
      },
      [
        createText(`00000 11111 22222 33333 444444 55555 66666 77777 88888 99999`)
      ]
    );
    append(BODY, cont);

    await snapshot();

    requestAnimationFrame(async () => {
      cont.style.transform = 'translate(100px, 0)';
      await snapshot(0.1);
      done();
    });
  });

  it('from none to not none and overflow is scroll', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
          transform: 'none',
          overflow: 'scroll',
        }
      },
      [
        createText(`00000 11111 22222 33333 444444 55555 66666 77777 88888 99999`)
      ]
    );
    append(BODY, cont);

    await snapshot();

    requestAnimationFrame(async () => {
      cont.style.transform = 'translate(100px, 0)';
      await snapshot(0.1);
      done();
    });
  });
});

