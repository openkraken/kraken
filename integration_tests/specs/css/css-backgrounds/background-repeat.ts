describe('background-repeat', () => {
  it('default should be repeat', async () => {
    // repeat
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url("assets/rabbit.png")',
    });
    repeat.appendChild(div1);
    document.body.appendChild(repeat);

    await snapshot(repeat);
  });

  it('none-repeat', async () => {
    // repeat
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundRepeat: 'no-repeat',
    });
    repeat.appendChild(div1);
    document.body.appendChild(repeat);

    await snapshot(repeat);
  });

  it('repeat-x', async () => {
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundRepeat: 'repeat-x',
    });
    repeat.appendChild(div2);
    append(BODY, repeat);

    await snapshot(repeat);
  });

  it('repeat-y', async () => {
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div3 = document.createElement('div');
    setElementStyle(div3, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundRepeat: 'repeat-y',
    });
    repeat.appendChild(div3);
    append(BODY, repeat);

    await snapshot(repeat);
  });

  it('repeat', async () => {
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div4 = document.createElement('div');
    setElementStyle(div4, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundRepeat: 'repeat',
    });
    repeat.appendChild(div4);
    append(BODY, repeat);

    await snapshot(repeat);
  });

  xit('round', async () => {
    let div = createElementWithStyle('div', {
      width: '220px',
      height: '220px',
      backgroundColor: 'red',
      backgroundImage:
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/cat.png)',
      backgroundRepeat: 'round',
    });
    append(BODY, div);
    await sleep(0.5);
    await snapshot(div);
  });

  xit('no-repeat will stop round to repeat', async () => {
    let div = createElementWithStyle('div', {
      width: '220px',
      height: '220px',
      backgroundColor: 'red',
      backgroundImage:
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/cat.png)',
      backgroundRepeat: 'round',
    });
    append(BODY, div);
    await sleep(0.5);
    await snapshot(div);
  });
});
