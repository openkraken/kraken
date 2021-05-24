/*auto generated*/
describe('flexbox_object', () => {
  it('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: '#ffcc00',
          'justify-content': 'space-around',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'p',
          {
            style: {
              background: '#3366cc',
              margin: '0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`this is a flex item`)]
        ),
        createElement(
          'p',
          {
            style: {
              background: '#3366cc',
              margin: '0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`this is a flex item`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
