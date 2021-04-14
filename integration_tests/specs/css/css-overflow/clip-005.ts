/*auto generated*/
describe('clip-005', () => {
  xit('ref', async () => {
    let inner;
    let inner_1;
    let inner_2;
    let outer;
    let outer_1;
    let outer_2;
    outer = createElement(
      'div',
      {
        class: 'outer',
        style: {
          width: '50px',
          height: '50px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          outline: '2px solid grey',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            background: 'blue',
            height: '50px',
            width: '50px',
            opacity: '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    outer_1 = createElement(
      'div',
      {
        class: 'outer',
        style: {
          width: '50px',
          height: '50px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          outline: '2px solid grey',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner_1 = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            background: 'blue',
            height: '100px',
            width: '50px',
            opacity: '0.5',
            'box-sizing': 'border-box',
            top: '-10px',
          },
        })),
      ]
    );
    outer_2 = createElement(
      'div',
      {
        class: 'outer',
        style: {
          width: '50px',
          height: '50px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          outline: '2px solid grey',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner_2 = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            background: 'blue',
            height: '50px',
            width: '100px',
            opacity: '0.5',
            'box-sizing': 'border-box',
            left: '-30px',
          },
        })),
      ]
    );
    BODY.appendChild(outer);
    BODY.appendChild(outer_1);
    BODY.appendChild(outer_2);

    await snapshot();
  });
});
