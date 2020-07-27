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
