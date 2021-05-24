/*auto generated*/
describe('orthogonal-flow', () => {
  it('with-inline-end-margin', async () => {
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'box-sizing': 'border-box',
          overflow: 'auto',
          width: '100px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
      [
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            'writing-mode': 'horizontal-tb',
            width: '100px',
            height: '100px',
            'margin-bottom': '200px',
            backgroundColor: 'green'
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
});
