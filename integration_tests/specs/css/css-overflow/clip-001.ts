/*auto generated*/
describe('clip-001', () => {
  it('ref', async () => {
    let fill;
    let target;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          overflow: 'auto',
          height: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (target = createElement(
          'div',
          {
            id: 'target',
            style: {
              width: '100px',
              height: '100px',
              background: 'red',
              overflow: 'hidden',
              'box-sizing': 'border-box',
            },
          },
          [
            (fill = createElement('div', {
              id: 'fill',
              style: {
                background: 'blue',
                height: '5000px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
});
