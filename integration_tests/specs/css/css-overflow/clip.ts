/*auto generated*/
xdescribe('clip', () => {
  xit('002', async () => {
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
          'box-sizing': 'border-box',
          overflow: 'clip',
        },
      },
      [
        (inner = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
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
          'box-sizing': 'border-box',
          'overflow-x': 'clip',
        },
      },
      [
        (inner_1 = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
            opacity: '0.5',
            'box-sizing': 'border-box',
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
          'box-sizing': 'border-box',
          'overflow-y': 'clip',
        },
      },
      [
        (inner_2 = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
            opacity: '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(outer);
    BODY.appendChild(outer_1);
    BODY.appendChild(outer_2);

    await snapshot();
  });
  it('003', async () => {
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
          overflow: 'auto',
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
              overflow: 'clip',
              outline: 'solid red',
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
              'overflow-x': 'clip',
            },
          },
          [
            (inner_1 = createElement('div', {
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
          overflow: 'auto',
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
              'overflow-x': 'clip',
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
              'overflow-y': 'clip',
            },
          },
          [
            (inner_3 = createElement('div', {
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
          overflow: 'auto',
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
              'overflow-y': 'clip',
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

    await snapshot(0.1);
  });
  xit('004', async () => {
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
          width: '30px',
          height: '30px',
          padding: '10px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          'box-sizing': 'border-box',
          overflow: 'clip',
        },
      },
      [
        (inner = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
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
          width: '30px',
          height: '30px',
          padding: '10px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          'box-sizing': 'border-box',
          'overflow-x': 'clip',
        },
      },
      [
        (inner_1 = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
            opacity: '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    outer_2 = createElement(
      'div',
      {
        class: 'outer',
        style: {
          width: '30px',
          height: '30px',
          padding: '10px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          'box-sizing': 'border-box',
          'overflow-y': 'clip',
        },
      },
      [
        (inner_2 = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
            opacity: '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(outer);
    BODY.appendChild(outer_1);
    BODY.appendChild(outer_2);

    await snapshot();
  });
  xit('005', async () => {
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
          width: '30px',
          height: '30px',
          padding: '10px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          outline: '2px solid grey',
          'box-sizing': 'border-box',
          overflow: 'clip',
        },
      },
      [
        (inner = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
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
          width: '30px',
          height: '30px',
          padding: '10px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          outline: '2px solid grey',
          'box-sizing': 'border-box',
          'overflow-x': 'clip',
        },
      },
      [
        (inner_1 = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
            opacity: '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    outer_2 = createElement(
      'div',
      {
        class: 'outer',
        style: {
          width: '30px',
          height: '30px',
          padding: '10px',
          'margin-left': '100px',
          'margin-top': '100px',
          background: 'black',
          outline: '2px solid grey',
          'box-sizing': 'border-box',
          'overflow-y': 'clip',
        },
      },
      [
        (inner_2 = createElement('div', {
          class: 'inner',
          style: {
            position: 'relative',
            top: '-20px',
            left: '-40px',
            background: 'blue',
            height: '100px',
            width: '100px',
            opacity: '0.5',
            'box-sizing': 'border-box',
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
