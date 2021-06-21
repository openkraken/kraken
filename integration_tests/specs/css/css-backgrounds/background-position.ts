describe('Background-position', () => {
  it('center', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/cat.png)',
      backgroundPosition: 'center',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position1);
    append(BODY, position);
    await snapshot(0.1);
  });

  it('left', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position2 = document.createElement('div');
    setElementStyle(position2, {
      width: '360px',
      height: '200px',
      backgroundImage: 'url(assets/rabbit.png)',
      backgroundPosition: 'left',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position2);

    append(BODY, position);
    await snapshot(0.1);
  });

  it('top', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position3 = document.createElement('div');
    setElementStyle(position3, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundPosition: 'top',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position3);

    append(BODY, position);
    await sleep(1);
    await snapshot();
  });

  it('right', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position4 = document.createElement('div');
    setElementStyle(position4, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundPosition: 'right',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position4);

    append(BODY, position);
    await sleep(1);
    await snapshot();
  });

  it('bottom', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });
    const position5 = document.createElement('div');
    setElementStyle(position5, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundPosition: 'bottom',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position5);
    append(BODY, position);
    await sleep(1);
    await snapshot();
  });

  it('right center', async () => {
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundPosition: 'right center',
      backgroundRepeat: 'no-repeat',
    });
    append(position, div);
    append(BODY, position);
    await sleep(1);
    await snapshot();
  });

  it('should works with length type', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) no-repeat yellow',
      backgroundPosition: '40px 60px',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });

  it('should works with length type and background-repeat of repeat', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) repeat yellow',
      backgroundPosition: '40px 60px',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });

  it('should works with percentage type', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) 80% 40% no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });

  it('should works with mixing type 1', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) 80% 40px no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });

  it('should works with mixing type 2', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) 40px top no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });

  it('should works with mixing type 3', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) 30% bottom no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });

  it('should works when background image size is bigger than container size', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '60px',
      height: '80px',
      background: 'url(assets/cat.png) 20px bottom no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });

  it('should works with background-position-x', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) no-repeat yellow',
      backgroundPositionX: '50px',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });

  it('should works with background-position-y', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) no-repeat yellow',
      backgroundPositionY: 'bottom',
    });
    append(BODY, position1);
    await snapshot(0.1);
  });
});
