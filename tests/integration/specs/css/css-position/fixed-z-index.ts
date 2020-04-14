describe('fixed-z-index', () => {
  fit('blend', async () => {
    let container = create('div', {}, [
      create('div', {
        display: 'block',
        position: 'fixed',
        zIndex: 2,
        width: '100px',
        height: '100px'
      }),
      create('div', {
        position: 'fixed',
        zIndex: 1,
        width: '100px',
        height: '100px',
        opacity: 1
      }),
      create('div', {
        position: 'relative',
        zIndex: 3,
        overflow: 'hidden',
        width: '100vw',
        height: '100vh',
        fontSize: '50px'
      }, [
        create('div', {
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