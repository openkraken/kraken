/*auto generated*/
describe('left-ltr', () => {
  xit('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
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
              border: '2px solid #000',
              'border-right-style': 'none',
              'padding-left': '5px',
              'margin-left': '30px',
            },
          },
          [createText(`One`)]
        ),
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
              border: '2px solid #000',
              'border-left-style': 'none',
              'padding-right': '10px',
              'margin-right': '60px',
            },
          },
          [createText(`Two`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
