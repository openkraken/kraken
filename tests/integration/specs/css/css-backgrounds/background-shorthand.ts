describe('background-shorthand', () => {
  it('background image', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '100vw',
      height: '200px',
      background: 'left top / contain repeat url(assets/rabbit.png)'
    });
    document.body.appendChild(div);
    await sleep(0.5);
    await matchElementImageSnapshot(div);
  });

  it('background gradient', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '100vw',
      height: '200px',
      background: 'center/contain repeat radial-gradient(crimson,skyblue)'
    });
    document.body.appendChild(div);
    await matchElementImageSnapshot(div);
  });

  it('background color', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '100vw',
      height: '200px',
      background: 'red'
    });
    document.body.appendChild(div);
    await matchElementImageSnapshot(div);
  });
});
