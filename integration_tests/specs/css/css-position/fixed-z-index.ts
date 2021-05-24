describe('fixed-z-index', () => {
  it('blend', async () => {
    let container = createElementWithStyle('div', {}, [
      createElementWithStyle('div', {
        display: 'block',
        position: 'fixed',
        zIndex: 2,
        width: '100px',
        height: '100px'
      }),
      createElementWithStyle('div', {
        position: 'fixed',
        zIndex: 1,
        width: '100px',
        height: '100px',
        opacity: 1
      }),
      createElementWithStyle('div', {
        position: 'relative',
        zIndex: 3,
        overflow: 'hidden',
        width: '360px',
        height: '640px',
        fontSize: '50px'
      }, [
        createElementWithStyle('div', {
          width: '10px',
          height: '10px',
          backgroundColor: 'red'
        })
      ])
    ]);
    BODY.appendChild(container);
    await snapshot();
  });
});
