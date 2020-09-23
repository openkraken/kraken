/*auto generated*/
describe('flexbox_stf-table', () => {
  it('singleline-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-block',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'p',
          {
            style: {
              display: 'inline-block',
              margin: '10px 0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`fillerfillerfillerfillerfiller`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });
});
