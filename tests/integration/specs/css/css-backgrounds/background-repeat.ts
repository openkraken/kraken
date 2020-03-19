describe('background-repeat', () => {
  it('none-repeat', async () => {
    // repeat
    const repeat = document.createElement('div');
    setStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div1 = document.createElement('div');
    setStyle(div1, {
      width: '100vw',
      height: '200px',
      backgroundImage: 'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundRepeat: 'no-repeat',
    });
    repeat.appendChild(div1);
    document.body.appendChild(repeat);
    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('repeat-x', async () => {
    const repeat = document.createElement('div');
    setStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div2 = document.createElement('div');
    setStyle(div2, {
      width: '100vw',
      height: '200px',
      backgroundImage: 'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundRepeat: 'repeat-x',
    });
    repeat.appendChild(div2);
    append(BODY, repeat);

    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('repeat-y', async () => {
    const repeat = document.createElement('div');
    setStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div3 = document.createElement('div');
    setStyle(div3, {
      width: '100vw',
      height: '200px',
      backgroundImage: 'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundRepeat: 'repeat-y',
    });
    repeat.appendChild(div3);
    append(BODY, repeat);
    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('repeat', async () => {
    const repeat = document.createElement('div');
    setStyle(repeat, {
      width: '100vw',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const div4 = document.createElement('div');
    setStyle(div4, {
      width: '100vw',
      height: '200px',
      backgroundImage: 'url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)',
      backgroundRepeat: 'repeat',
    });
    repeat.appendChild(div4);
    append(BODY, repeat);
    await sleep(1);
    await expectAsync(repeat.toBlob(1.0)).toMatchImageSnapshot();
  });
});