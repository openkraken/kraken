/*auto generated*/
describe('flex-box', () => {
  xit('wrap', async () => {
    let p;
    let flexItem;
    let flexItem_1;
    let error;
    let flexBox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a green block with no red.`)]
    );
    flexBox = createElement(
      'div',
      {
        class: 'flex-box',
        style: {
          position: 'relative',
          display: 'flex',
          'flex-wrap': 'wrap',
          margin: '0',
          'padding-left': '0',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '120px',
              height: '100px',
              'background-color': 'green',
              'box-sizing': 'border-box',
            },
          },
          [createText(`width: 120px`)]
        )),
        (flexItem_1 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '120px',
              height: '100px',
              'background-color': 'green',
              'box-sizing': 'border-box',
            },
          },
          [createText(`width: 120px`)]
        )),
        (error = createElement('div', {
          class: 'error',
          style: {
            width: '120px',
            height: '100px',
            'background-color': 'red',
            position: 'absolute',
            top: '100px',
            left: '0',
            'z-index': '-1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexBox);

    await snapshot();
  });
});
