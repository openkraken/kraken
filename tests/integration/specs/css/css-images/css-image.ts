/*auto generated*/
describe('css-image', () => {
  it('fallbacks-and-annotations-ref', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'green',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await matchScreenshot();
  });
  xit('fallbacks-and-annotations', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        background: 'image("green.png", green)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await matchScreenshot();
  });
  xit('fallbacks-and-annotations002', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        color: 'white',
        'background-color': 'red',
        'background-image': 'image("assets/1x1-green.png")',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await matchScreenshot();
  });
  xit('fallbacks-and-annotations003', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        'background-image':
          'image("1x1-green.svg", "assets/1x1-green.png","assets/1x1-green.gif")',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await matchScreenshot();
  });
  xit('fallbacks-and-annotations004', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        'background-image':
          'image("1x1-green.svg", "1x1-green.png", "assets/1x1-green.gif")',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await matchScreenshot();
  });
  xit('fallbacks-and-annotations005', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if background is pale green and no green and no red.`
        ),
      ]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        'background-image':
          'image(rgba(0,0,255,0.5)), url("assets/1x1-green.png")',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await matchScreenshot();
  });
});
