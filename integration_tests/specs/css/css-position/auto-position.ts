/*auto generated*/
describe('auto-position', () => {
  it('rtl-child-viewport-scrollbar-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        width: '100px',
        height: '100px',
        background: 'green',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('rtl-child-viewport-scrollbar', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          direction: 'rtl',
          width: '80px',
          height: '80px',
          border: '10px solid green',
          background: 'red',
        },
      },
      [
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            position: 'absolute',
            width: '80px',
            height: '80px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
