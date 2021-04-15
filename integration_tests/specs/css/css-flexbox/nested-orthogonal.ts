/*auto generated*/
describe('nested-orthogonal', () => {
  it('flexbox-relayout-ref', async () => {
    let item;
    let row;
    let column;
    column = createElement(
      'div',
      {
        id: 'column',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          border: '5px solid yellow',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (row = createElement(
          'div',
          {
            id: 'row',
            style: {
              display: 'flex',
              'flex-direction': 'row',
              border: '5px solid blue',
              'box-sizing': 'border-box',
            },
          },
          [
            (item = createElement(
              'div',
              {
                class: 'item',
                style: {
                  border: '5px solid green',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`This text should not overflow its box`)]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(column);

    await snapshot();
  });
  it('flexbox-relayout', async () => {
    let item;
    let row;
    let column;
    column = createElement(
      'div',
      {
        id: 'column',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          border: '5px solid yellow',
          'box-sizing': 'border-box',
          width: '200px',
        },
      },
      [
        (row = createElement(
          'div',
          {
            id: 'row',
            style: {
              display: 'flex',
              'flex-direction': 'row',
              border: '5px solid blue',
              'box-sizing': 'border-box',
            },
          },
          [
            (item = createElement(
              'div',
              {
                class: 'item',
                style: {
                  border: '5px solid green',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`This text should not overflow its box`)]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(column);

    await snapshot();
  });
});
