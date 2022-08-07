describe('vw-vh', () => {
  it('basic', async () => {
    const style = {
      backgroundColor: 'green',
      width: '50vw',
      height: '50vh',
    };
    let div = <div style={style} />;

    BODY.appendChild(div);
    await snapshot();
  });

  it('transition', done => {
    const style = {
      position: 'absolute',
      top: '0',
      left: 0,
      width: '50vw',
      height: '20vh',
      transition: 'all 0.1s ease-out',
      backgroundColor: 'green'
    };
    let div = <div style={style} />;

    BODY.appendChild(div);

    div.addEventListener('transitionend', async () => {
      await snapshot();
      BODY.removeChild(div);
      done();
    });

    requestAnimationFrame(() => {
      setElementStyle(div, {
        top: '50vh',
      });
    });
  });
});
