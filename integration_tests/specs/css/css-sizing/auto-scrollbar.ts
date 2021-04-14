/*auto generated*/
describe('auto-scrollbar', () => {
  it('inside-stf-abspos-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The word PASS should be visible below.`)]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          position: 'absolute',
          height: '50px',
          'overflow-y': 'scroll',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              height: '150px',
            },
          },
          [createText(`PASS`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('inside-stf-abspos', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The word PASS should be visible below.`)]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          position: 'absolute',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              height: '50px',
              'overflow-y': 'auto',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  height: '150px',
                },
              },
              [createText(`PASS`)]
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
