describe('background-shorthand', () => {
  it('background image', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '360px',
      height: '200px',
      background: 'left top / contain repeat url(assets/rabbit.png)'
    });
    document.body.appendChild(div);
    await sleep(0.5);
    await snapshot(div);
  });

  it('background gradient', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '360px',
      height: '200px',
      background: 'center/contain repeat radial-gradient(crimson,skyblue)'
    });
    document.body.appendChild(div);
    await snapshot(div);
  });

  it('background color', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '360px',
      height: '200px',
      background: 'red'
    });
    document.body.appendChild(div);
    await snapshot(div);
  });

  it('background color rgb', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '360px',
      height: '200px',
      background: 'rgb(255, 0, 0)'
    });
    document.body.appendChild(div);
    await snapshot(div);
  });

  it("background gradient with space", async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is no red visible on the page.`)]
    );
    flexbox = createElement('div', {
      style: {
        background:
          'linear-gradient(to bottom, green 0%, green 25%, red 25%, red 75%, green 75% green 100%)',
        'align-content': 'center',
        display: 'flex',
        'flex-flow': 'wrap',
        height: '100px',
        width: '300px',
        'box-sizing': 'border-box',
      },
    });
    document.body.appendChild(p);
    document.body.appendChild(flexbox);


    await snapshot();
  })
});
