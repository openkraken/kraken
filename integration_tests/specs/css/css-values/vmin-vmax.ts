describe('vmin-vmax', () => {
  it('basic', async () => {
    const style = {
      backgroundColor: 'green',
      width: '50vmin',
      height: '50vmax',
    };
    let div = <div style={style} />;
    BODY.appendChild(div);

    await snapshot();
  });

  it('transition', done => {
    const style = {
      position: 'absolute',
      top: 0,
      left: 0,
      width: '50vmin',
      height: '20vmax',
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
        top: '50vmin',
      });
    });
  });
});
