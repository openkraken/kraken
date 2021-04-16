/*auto generated*/
describe('flexbox_nested', () => {
  it('flex', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: '#3366cc',
          border: '1px solid black',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'p',
          {
            style: {
              background: 'yellow',
              margin: '10px',
              width: '200px',
              height: '20px',
              display: 'flex',
              'box-sizing': 'border-box',
            },
          },
          [createText(`xxx`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
