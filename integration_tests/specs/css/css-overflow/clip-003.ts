/*auto generated*/
describe('clip-003', () => {
  xit('ref', async () => {
    let inner;
    let inner_1;
    let inner_2;
    let inner_3;
    let inner_4;
    let outer;
    let outer_1;
    let outer_2;
    let outer_3;
    let outer_4;
    let wrapper;
    let wrapper_1;
    let wrapper_2;
    let wrapper_3;
    let wrapper_4;
    wrapper = createElement(
      'div',
      {
        class: 'wrapper',
        style: {
          'margin-left': '30px',
          'margin-bottom': '20px',
          width: '50px',
          height: '50px',
          'box-sizing': 'border-box',
          overflow: 'hidden',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            style: {
              width: '50px',
              height: '50px',
              background: 'black',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement('div', {
              class: 'inner',
              style: {
                position: 'relative',
                top: '-10px',
                left: '-10px',
                height: '100px',
                width: '100px',
                background: 'blue',
                opacity: '0.5',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    wrapper_1 = createElement(
      'div',
      {
        class: 'wrapper',
        style: {
          'margin-left': '30px',
          'margin-bottom': '20px',
          width: '50px',
          height: '50px',
          'box-sizing': 'border-box',
          outline: 'solid',
        },
      },
      [
        (outer_1 = createElement(
          'div',
          {
            class: 'outer',
            style: {
              width: '50px',
              height: '50px',
              background: 'black',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner_1 = createElement('div', {
              class: 'inner',
              style: {
                position: 'relative',
                top: '-10px',
                left: '0',
                height: '100px',
                width: '50px',
                background: 'blue',
                opacity: '0.5',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    wrapper_2 = createElement(
      'div',
      {
        class: 'wrapper',
        style: {
          'margin-left': '30px',
          'margin-bottom': '20px',
          width: '50px',
          height: '50px',
          'box-sizing': 'border-box',
          overflow: 'hidden scroll',
          'margin-top': '50px',
        },
      },
      [
        (outer_2 = createElement(
          'div',
          {
            class: 'outer',
            style: {
              width: '50px',
              height: '50px',
              background: 'black',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner_2 = createElement('div', {
              class: 'inner',
              style: {
                position: 'relative',
                top: '-10px',
                left: '-10px',
                height: '100px',
                width: '1px',
                background: 'blue',
                opacity: '0.5',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    wrapper_3 = createElement(
      'div',
      {
        class: 'wrapper',
        style: {
          'margin-left': '30px',
          'margin-bottom': '20px',
          width: '50px',
          height: '50px',
          'box-sizing': 'border-box',
          outline: 'solid',
        },
      },
      [
        (outer_3 = createElement(
          'div',
          {
            class: 'outer',
            style: {
              width: '50px',
              height: '50px',
              background: 'black',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner_3 = createElement('div', {
              class: 'inner',
              style: {
                position: 'relative',
                top: '0',
                left: '-10px',
                height: '50px',
                width: '100px',
                background: 'blue',
                opacity: '0.5',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    wrapper_4 = createElement(
      'div',
      {
        class: 'wrapper',
        style: {
          'margin-left': '30px',
          'margin-bottom': '20px',
          width: '50px',
          height: '50px',
          'box-sizing': 'border-box',
          overflow: 'scroll hidden',
        },
      },
      [
        (outer_4 = createElement(
          'div',
          {
            class: 'outer',
            style: {
              width: '50px',
              height: '50px',
              background: 'black',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner_4 = createElement('div', {
              class: 'inner',
              style: {
                position: 'relative',
                top: '-10px',
                left: '-10px',
                height: '1px',
                width: '100px',
                background: 'blue',
                opacity: '0.5',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(wrapper);
    BODY.appendChild(wrapper_1);
    BODY.appendChild(wrapper_2);
    BODY.appendChild(wrapper_3);
    BODY.appendChild(wrapper_4);

    await snapshot();
  });
});
