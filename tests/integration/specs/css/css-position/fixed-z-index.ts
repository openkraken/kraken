describe('fixed-z-index', () => {
  it('blend', async () => {
    let container = createElement('div', {}, [
      createElement('div', {
        display: 'block',
        position: 'fixed',
        zIndex: 2,
        width: '100px',
        height: '100px'
      }),
      createElement('div', {
        position: 'fixed',
        zIndex: 1,
        width: '100px',
        height: '100px',
        opacity: 1
      }),
      createElement('div', {
        position: 'relative',
        zIndex: 3,
        overflow: 'hidden',
        width: '100vw',
        height: '100vh',
        fontSize: '50px'
      }, [
        createElement('div', {
          width: '10px',
          height: '10px',
          backgroundColor: 'red'
        })
      ])
    ]);
    BODY.appendChild(container);
    await matchScreenshot();
  });
});
