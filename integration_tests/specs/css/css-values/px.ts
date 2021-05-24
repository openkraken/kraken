describe('px', () => {
  it('basic', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          backgroundColor: 'green',
          width: '100px',
          height: '100px',
        },
      },
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('transition', done => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          position: 'absolute',
          top: '0',
          left: 0,
          width: '200px',
          height: '100px',
          transition: 'all 0.5s ease-out',
          backgroundColor: 'green'
        },
      },
    );
    BODY.appendChild(div);

    requestAnimationFrame(() => {
      setElementStyle(div, {
        top: '200px',
      });

      // Wait for animation finished.
      setTimeout(async () => {
        await snapshot();
        done();
      }, 600);
    });
  });
});
