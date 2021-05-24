/*auto generated*/
describe('flexbox_margin-collapse', () => {
  it('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'p',
          {
            style: {
              margin: '10px 0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'p',
          {
            style: {
              margin: '20px 0 10px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
