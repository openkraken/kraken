describe('Background-position', () => {
  it('center', async () => {
    // position
    const position = document.createElement('div');
    setStyle(position, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position1 = document.createElement('div');
    setStyle(position1, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/cat.png)',
      backgroundPosition: 'center',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position1);
    append(BODY, position);
    await sleep(1);
    await matchElementImageSnapshot(position);
  });

  it('left', async () => {
    // position
    const position = document.createElement('div');
    setStyle(position, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position2 = document.createElement('div');
    setStyle(position2, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundPosition: 'left',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position2);

    append(BODY, position);
    await sleep(1);
    await matchElementImageSnapshot(position);
  });

  it('top', async () => {
    // position
    const position = document.createElement('div');
    setStyle(position, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position3 = document.createElement('div');
    setStyle(position3, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundPosition: 'top',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position3);

    append(BODY, position);
    await sleep(1);
    await matchElementImageSnapshot(position);
  });

  it('right', async () => {
    // position
    const position = document.createElement('div');
    setStyle(position, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position4 = document.createElement('div');
    setStyle(position4, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundPosition: 'right',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position4);

    append(BODY, position);
    await sleep(1);
    await matchElementImageSnapshot(position);
  });

  it('bottom', async () => {
    // position
    const position = document.createElement('div');
    setStyle(position, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });
    const position5 = document.createElement('div');
    setStyle(position5, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundPosition: 'bottom',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position5);
    append(BODY, position);
    await sleep(1);
    await matchElementImageSnapshot(position);
  });

  it('right center', async () => {
    const position = document.createElement('div');
    setStyle(position, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });
    const div = document.createElement('div');
    setStyle(div, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundPosition: 'right center',
      backgroundRepeat: 'no-repeat',
    });
    append(position, div);
    append(BODY, position);
    await sleep(1);
    await matchElementImageSnapshot(position);
  });
});
