describe('vw-vh', () => {
  it('basic', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          backgroundColor: 'green',
          width: '50vw',
          height: '50vh',
        },
      },
    );
    BODY.appendChild(div);

    await matchViewportSnapshot();
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
          width: '50vw',
          height: '20vh',
          transition: 'all 0.5s ease-out',
          backgroundColor: 'green'
        },
      },
    );
    BODY.appendChild(div);

    requestAnimationFrame(() => {
      setElementStyle(div, {
        top: '50vh',
      });

      // Wait for animation finished.
      setTimeout(async () => {
        await matchViewportSnapshot();
        done();
      }, 600);
    });
  });
});
