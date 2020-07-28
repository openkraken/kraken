describe('line-height', () => {
  it('with unit of px', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createText(`line height 100px`),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  fit('with unit of rpx', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '300rpx',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '300rpx',
          height: '300rpx',
        },
      },
      [
        createText(`line height 300rpx`),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with unit of vw', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '20vw',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '20vw',
        },
      },
      [
        createText(`line height 20vw`),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with unit of vh', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '20vh',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '20vh',
        },
      },
      [
        createText(`line height 20vh`),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with unit of number', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '3',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createText(`line height 3`),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with block element', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
        'div',
        {
            style: {
            lineHeight: '2',
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '16px',
            width: '200px',
            height: '50px',
            },
        },[
            createText(`line height 2`),
        ])
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with inline element', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
        'span',
        {
            style: {
            lineHeight: '2',
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '16px',
            width: '200px',
            height: '50px',
            },
        },[
            createText(`line height 2`),
        ])
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with flex item', async () => {
    const div = createElement(
      'div',
      {
        style: {
            display: 'flex',
            flexDirection: 'column',
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
        'div',
        {
            style: {
            lineHeight: '2',
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '16px',
            width: '200px',
            height: '50px',
            },
        },[
            createText(`line height 2`),
        ]),
        createElement(
        'div',
        {
            style: {
            lineHeight: '2',
            'box-sizing': 'border-box',
            'backgroundColor': 'red',
            fontSize: '16px',
            width: '200px',
            height: '50px',
            },
        },[
            createText(`line height 2`),
        ])
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with multiple lines', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
        'div',
        {
            style: {
            lineHeight: '2',
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '16px',
            width: '200px',
            height: '50px',
            },
        },[
            createText(`line height 2`),
        ]),
        createElement(
        'div',
        {
            style: {
            lineHeight: '2',
            'box-sizing': 'border-box',
            'backgroundColor': 'red',
            fontSize: '16px',
            width: '200px',
            height: '50px',
            },
        },[
            createText(`line height 2`),
        ])
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });
});
