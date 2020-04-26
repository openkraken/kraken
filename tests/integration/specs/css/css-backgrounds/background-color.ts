describe('Background-color', () => {
  it('red', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '200px',
      height: '200px',
      backgroundColor: 'red',
    });

    document.body.appendChild(div);
    await expectAsync(div.toBlob(1.0)).toMatchImageSnapshot();
  });

  xit('red with display none', async () => {
    const div = createElement('div', {
      backgroundColor: 'red',
      display: 'none',
      width: '100px',
      height: '100px',
    });
    append(BODY, div);
    await matchElementImageSnapshot(div);
  });

  xit('red with display when window.onload', done => {
    window.onload = async () => {
      div.style.display = 'none';
      await matchScreenshot();
      done();
    };
    const div = createElement('div', {
      backgroundColor: 'red',
      width: '100px',
      height: '100px',
    });
    append(BODY, div);
  });

  it('image overlay red', async () => {
    let red = createElement('div', {
      width: '60px',
      height: '60px',
      backgroundColor: 'red',
    });
    let green = createElement('div', {
      width: '100px',
      height: '100px',
      position: 'relative',
      bottom: '60px',
      backgroundImage:
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/green-60-60.png)',
      backgroundRepeat: 'no-repeat',
    });
    append(BODY, red);
    append(BODY, green);
    await sleep(1);
    await matchScreenshot();
  });
});
