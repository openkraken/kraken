describe('containing-block', () => {

  it('001', async () => {
    let div1 = create('div', {
      backgroundColor: 'red',
      display: 'block',
      width: '100px',
      height: '100px'
    });
    let child = create('div', {
      backgroundColor: 'green',
      height: '100px',
      width: '100px',
      position: 'relative'
    });
    append(div1, child);
    append(BODY, div1);
    await matchElementImageSnapshot(div1);
  });

  it('003', async () => {
    let div1 = create('div', {
      width: '60px',
      height: '60px',
      padding: '20px',
      display: 'inline-block',
      backgroundColor: 'red'
    });
    let child = create('div', {
      backgroundColor: 'green',
      height: '100px',
      width: '100px',
      left: '-20px',
      position: 'relative',
      top: '-20px'
    });
    append(div1, child);
    append(BODY, div1);
    await matchScreenshot();
  });

  xit('004', async () => {
    let div1 = create('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      display: 'block'
    });
    let child = create('div', {
      backgroundColor: 'green',
      height: '100%',
      width: '100%',
      position: 'static'
    });
    append(div1, child);
    append(BODY, div1);
    await matchElementImageSnapshot(div1);
  });

  it('007', async () => {
    let div1 = create('div', {
      position: 'relative',
      bottom: 0
    });
    let child = create('div', {
      backgroundColor: 'blue',
      height: '100px',
      position: 'fixed',
      right: 0,
      top: 0,
      width: '100px'
    });
    append(div1, child);
    append(BODY, div1);
    await matchScreenshot();
  });

  xit('008', async () => {
    let div1 = create('div', {
      border: '1px solid black',
      margin: '50px',
      position: 'absolute',
      top: 0
    });
    let div2 = create('div', {
      margin: '50px',
      width: '100px',
      height: '100px'
    });
    let div3 = create('div', {
      backgroundColor: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '100px',
      height: '100px'
    });
    append(div2, div3);
    append(div1, div2);
    append(BODY, div1);
    await matchScreenshot();
  });
  xit('009', async () => {
    let div1 = create('div', {
      border: '1px solid black',
      margin: '50px',
      position: 'relative',
      top: 0
    });
    let div2 = create('div', {
      margin: '50px',
      width: '100px',
      height: '100px'
    });
    let div3 = create('div', {
      backgroundColor: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '100px',
      height: '100px'
    });
    append(div2, div3);
    append(div1, div2);
    append(BODY, div1);
    await matchElementImageSnapshot(BODY);
  });
  xit('010', async () => {
    let div1 = create('div', {
      border: '1px solid black',
      margin: '50px',
      position: 'fixed',
      top: 0
    });
    let div2 = create('div', {
      margin: '50px',
      width: '100px',
      height: '100px'
    });
    let div3 = create('div', {
      backgroundColor: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '100px',
      height: '100px'
    });
    append(div2, div3);
    append(div1, div2);
    append(BODY, div1);
    await matchElementImageSnapshot(BODY);
  });
  xit('011', async () => {
    let div2 = create('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'relative',
      width: 0
    });
    let span = create('span', {
      backgroundColor: 'blue',
      height: '100px',
      position: 'absolute',
      width: '100px'
    });
    append(div2, span);
    append(BODY, div2);
    await matchElementImageSnapshot(BODY);
  });
  xit('013', async () => {
    let div2 = create('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'absolute',
      width: 0
    });
    let span = create('span', {
      backgroundColor: 'blue',
      height: '100px',
      width: '100px',
      position: 'absolute'
    });
    append(div2, span);
    append(BODY, div2);
    await matchElementImageSnapshot(BODY);
  });
});