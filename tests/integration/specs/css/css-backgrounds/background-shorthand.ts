describe('background-shorthand', () => {
  it('background image', async () => {
    let div = document.createElement('div');
    setStyle(div, {
      width: '100vw',
      height: '200px',
      background: 'left top / contain repeat url(https://img.alicdn.com/tfs/TB1H2Kcb1H2gK0jSZFEXXcqMpXa-70-72.png)'
    });
    document.body.appendChild(div);
    await sleep(1);
    await matchElementImageSnapshot(div);
  });

  it('background gradient', async () => {
    let div = document.createElement('div');
    setStyle(div, {
      width: '100vw',
      height: '200px',
      background: 'center/contain repeat radial-gradient(crimson,skyblue)'
    });
    document.body.appendChild(div);
    await sleep(1);
    await matchElementImageSnapshot(div);
  });

  it('background color', async () => {
    let div = document.createElement('div');
    setStyle(div, {
      width: '100vw',
      height: '200px',
      background: 'red'
    });
    document.body.appendChild(div);
    await sleep(1);
    await matchElementImageSnapshot(div);
  });
});
