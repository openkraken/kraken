describe('background-repeat', () => {
  it('default should be repeat', async () => {
    // repeat
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url("https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png")',
    });
    repeat.appendChild(div1);
    document.body.appendChild(repeat);
    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('none-repeat', async () => {
    // repeat
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundRepeat: 'no-repeat',
    });
    repeat.appendChild(div1);
    document.body.appendChild(repeat);
    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('repeat-x', async () => {
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundRepeat: 'repeat-x',
    });
    repeat.appendChild(div2);
    append(BODY, repeat);

    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('repeat-y', async () => {
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div3 = document.createElement('div');
    setElementStyle(div3, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundRepeat: 'repeat-y',
    });
    repeat.appendChild(div3);
    append(BODY, repeat);
    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('repeat', async () => {
    const repeat = document.createElement('div');
    setElementStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div4 = document.createElement('div');
    setElementStyle(div4, {
      width: '100vw',
      height: '200px',
      backgroundImage:
        'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundRepeat: 'repeat',
    });
    repeat.appendChild(div4);
    append(BODY, repeat);
    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
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
    await sleep(1);
    await matchElementImageSnapshot(div);
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
    await sleep(1);
    await matchElementImageSnapshot(div);
  });
});
