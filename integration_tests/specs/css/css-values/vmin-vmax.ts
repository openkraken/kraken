describe('vmin-vmax', () => {
  it('basic', async () => {
    const style = {
      backgroundColor: 'green',
      width: '50vmin',
      height: '50vmax',
    };
    let div = <div style={style} />;
    BODY.appendChild(div);

    await matchViewportSnapshot();
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
      await matchViewportSnapshot();
      done();
    });

    requestAnimationFrame(() => {
      setElementStyle(div, {
        top: '50vmin',
      });
    });
  });
});
