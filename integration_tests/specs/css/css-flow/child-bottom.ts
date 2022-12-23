/*auto generated*/
describe('child-bottom', () => {
  it('margin-in-unresolvable-percentage-height', async () => {
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
          position: 'relative',
          width: '100px',
          height: '100px',
          background: 'red',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              position: 'absolute',
              width: '100%',
              background: 'green',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  height: '100%',
                },
              },
              [
                createElement('div', {
                  style: {
                    'box-sizing': 'border-box',
                    'margin-bottom': '80px',
                    height: '20px',
                  },
                }),
              ]
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
