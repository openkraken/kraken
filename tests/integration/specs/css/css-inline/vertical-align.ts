describe('vertical-align', () => {
  it('with baseline', async () => {
    const div = createElement(
      'div',
      {
        style: {
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
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '35px',
            width: '200px',
            height: '50px',
            vertialAlign: 'baseline',
            },
        },[
            createText(`ABCD`),
        ]),
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'red',
            fontSize: '16px',
            width: '200px',
            height: '50px',
            },
        },[
            createText(`1234`),
        ])
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with top', async () => {
    const div = createElement(
      'div',
      {
        style: {
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
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '35px',
            width: '200px',
            },
        },[
            createText(`ABCD`),
        ]),
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'red',
            fontSize: '16px',
            width: '200px',
            verticalAlign: 'top',

            },
        },[
            createText(`1234`),
        ])
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });

  it('with bottom', async () => {
    const div = createElement(
      'div',
      {
        style: {
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
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '35px',
            width: '200px',
            },
        },[
            createText(`ABCD`),
        ]),
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'red',
            fontSize: '16px',
            width: '200px',
            verticalAlign: 'bottom',

            },
        },[
            createText(`1234`),
        ])
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });
});
