/*auto generated*/
describe('flex-item', () => {
  it('and-percentage-abspos', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              overflow: 'hidden',
              position: 'relative',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '100%',
                height: '100%',
                position: 'absolute',
                top: '0',
                left: '0',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '100px',
                height: '100px',
                background: 'green',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });
});
