describe('Transform', () => {
  it('translate', async () => {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'translate(10px, 6px )',
      })
    );

    await matchScreenshot();
  });

  it('scale', async () => {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'scale(0.6, 0.8)',
      })
    );

    await matchScreenshot();
  });

  it('skew', async () => {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'skew(-5deg)',
      })
    );

    await matchScreenshot();
  });

  it('matrix', async () => {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'matrix(0,1,1,1,10,10)',
      })
    );

    await matchScreenshot();
  });

  it('rotate', async () => {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'rotate(5deg)',
      })
    );

    await matchScreenshot();
  });

  it('matrix3d', async () => {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'matrix3d(0,1,1,1,10,10,1,0,0,1,1,1,1,1,0)',
      })
    );

    await matchScreenshot();
  });

  it('scale3d', async () => {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'scale3d(0.6, 0.8, 0.3) rotate3d(5deg, 8deg, 3deg)',
      })
    );

    await matchScreenshot();
  });
});
