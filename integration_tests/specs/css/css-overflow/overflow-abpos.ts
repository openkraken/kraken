/*auto generated*/
describe('overflow-abpos', () => {
  it('transform', async () => {
    let target;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          position: 'relative',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (target = createElement('div', {
          id: 'target',
          style: {
            position: 'absolute',
            width: '150px',
            height: '150px',
            'margin-left': '100px',
            transform: 'translateX(-100px)',
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
});
