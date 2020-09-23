/*auto generated*/
describe('flexbox-gap', () => {
  it('position-absolute-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-flex',
          background: 'fuchsia',
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
          [createText(`B`)]
        ),
        createElement('span', {
          style: {
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`C`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });
});
