describe('Text LineClamp', () => {
  it('should work with positive number', async () => {
    const cont = createElement(
      'div',
      {
        style: {
          width: '200px',
          lineClamp: 3,
        }
      },
      [
        createText(`hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world`)
      ]
    );
    append(BODY, cont);

    await matchViewportSnapshot();
  });

  it('should work with none', async () => {
    const cont = createElement(
      'div',
      {
        style: {
          width: '200px',
          lineClamp: 'none',
        }
      },
      [
        createText(`hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world`)
      ]
    );
    append(BODY, cont);

    await matchViewportSnapshot();
  });

  it('should work with none to positive number', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          width: '200px',
          lineClamp: 'none',
        }
      },
      [
        createText(`hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world`)
      ]
    );
    append(BODY, cont);

    setTimeout(async () => {
      // @ts-ignore
      cont.style.lineClamp = 3;
      await matchViewportSnapshot();
      done();
    }, 100);

    await matchViewportSnapshot();
  });

  it('should work with positive number to none', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          width: '200px',
          lineClamp: 3,
        }
      },
      [
        createText(`hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world`)
      ]
    );
    append(BODY, cont);

    setTimeout(async () => {
      // @ts-ignore
      cont.style.lineClamp = 'none';
      await matchViewportSnapshot();
      done();
    }, 100);

    await matchViewportSnapshot();
  });
});
