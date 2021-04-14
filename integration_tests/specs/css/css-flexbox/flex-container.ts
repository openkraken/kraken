/*auto generated*/
describe('flex-container', () => {
  it('margin', async () => {
    let flexItem;
    let flexItem_1;
    let flexItem_2;
    let flexContainer;
    flexContainer = createElement(
      'div',
      {
        class: 'flex-container',
        style: {
          display: 'flex',
          margin: '20px',
          background: '#333',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem = createElement('div', {
          class: 'flex-item',
          style: {
            width: '50px',
            height: '50px',
            margin: '20px',
            background: '#eee',
            'box-sizing': 'border-box',
          },
        })),
        (flexItem_1 = createElement('div', {
          class: 'flex-item',
          style: {
            width: '50px',
            height: '50px',
            margin: '20px',
            background: '#eee',
            'box-sizing': 'border-box',
          },
        })),
        (flexItem_2 = createElement('div', {
          class: 'flex-item',
          style: {
            width: '50px',
            height: '50px',
            margin: '20px',
            background: '#eee',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(flexContainer);

    await snapshot();
  });
});
