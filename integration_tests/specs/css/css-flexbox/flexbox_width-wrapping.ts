/*auto generated*/
describe('flexbox_width-wrapping', () => {
  xit('column', async () => {
    let log;
    let p;
    let item;
    let item_1;
    let item_2;
    let item_3;
    let test;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The green boxes should all be within the black box`)]
    );
    test = createElement(
      'div',
      {
        class: 'flexbox column wrap',
        id: 'test',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          '-webkit-flex-wrap': 'wrap',
          'flex-wrap': 'wrap',
          width: '600px',
          height: '60px',
          outline: '2px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (item = createElement('div', {
          class: 'item',
          'data-expected-width': '290',
          style: {
            height: '20px',
            'background-color': 'green',
            margin: '5px',
            'box-sizing': 'border-box',
          },
        })),
        (item_1 = createElement('div', {
          class: 'item',
          'data-expected-width': '290',
          style: {
            height: '20px',
            'background-color': 'green',
            margin: '5px',
            'box-sizing': 'border-box',
          },
        })),
        (item_2 = createElement('div', {
          class: 'item',
          'data-expected-width': '290',
          style: {
            height: '20px',
            'background-color': 'green',
            margin: '5px',
            'box-sizing': 'border-box',
          },
        })),
        (item_3 = createElement('div', {
          class: 'item',
          'data-expected-width': '290',
          style: {
            height: '20px',
            'background-color': 'green',
            margin: '5px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(p);
    BODY.appendChild(test);

    await snapshot();
  });
});
