/*auto generated*/
describe('overflow-inline', () => {
  it('transform-relative', async () => {
    let target;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          border: '1px solid black',
          width: '200px',
          overflow: 'auto',
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
            createText(`
    scroll
    `),
            (target = createElement('div', {
              id: 'target',
              style: {
                display: 'inline-block',
                width: '20px',
                height: '20px',
                background: 'green',
                position: 'relative',
                top: '100px',
                transform: 'translateY(80px)',
                'box-sizing': 'border-box',
              },
            })),
            createText(`
    down
  `),
          ]
        ),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
});
