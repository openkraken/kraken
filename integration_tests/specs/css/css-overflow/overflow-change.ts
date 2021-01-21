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
});
