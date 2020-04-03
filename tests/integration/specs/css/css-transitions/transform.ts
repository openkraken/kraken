describe('Transition transform', () => {
  it('001', done => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transitionProperty: 'transform',
      transitionDuration: '1s',
      transitionTimingFunction: 'ease',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(() => {
      setStyle(container1, {
        transform: 'translate3d(200px, 0, 0)',
      });

      // Wait for animation finished.
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});
