/*auto generated*/
describe('abspos-negative', () => {
  it('margin-001-ref', async () => {
    let blue;
    let blue_1;
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          'font-size': '10px',
          'line-height': '1',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`x`),
        (blue = createElement('span', {
          class: 'blue',
          style: {
            display: 'inline-block',
            'vertical-align': 'bottom',
            width: '10px',
            height: '10px',
            background: 'blue',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'font-size': '10px',
          'line-height': '1',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`x`),
        createElement('br', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
        (blue_1 = createElement('span', {
          class: 'blue',
          style: {
            display: 'inline-block',
            'vertical-align': 'bottom',
            width: '10px',
            height: '10px',
            background: 'blue',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('margin-001', async () => {
    let abspos;
    let abspos_1;
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  'box-sizing': 'border-box',
                  'margin-right': '-10px',
                },
              },
              [
                createText(`
        x`),
                (abspos = createElement('span', {
                  class: 'abspos',
                  style: {
                    position: 'absolute',
                    width: '10px',
                    height: '10px',
                    background: 'blue',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            ),
          ]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  'box-sizing': 'border-box',
                  'margin-right': '-10px',
                },
              },
              [
                createText(`
        x`),
                (abspos_1 = createElement('div', {
                  class: 'abspos',
                  style: {
                    position: 'absolute',
                    width: '10px',
                    height: '10px',
                    background: 'blue',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
});
