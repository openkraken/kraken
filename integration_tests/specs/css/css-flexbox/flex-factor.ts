/*auto generated*/
describe('flex-factor', () => {
  xit('less-than-one', async () => {
    let log;
    let childFlexGrow05;
    let childFlexGrow05_1;
    let childFlexGrow05_2;
    let childFlexGrow05_3;
    let childFlexGrow05_4;
    let childFlexGrow05_5;
    let childFlexGrow05_6;
    let childFlexGrow05_7;
    let childFlexGrow05_8;
    let childFlexGrow05_9;
    let childFlexGrow05_10;
    let childFlexGrow05_11;
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    let flexbox_3;
    let flexbox_4;
    let flexbox_5;
    let flexbox_6;
    let flexbox_7;
    let flexbox_8;
    let flexbox_9;
    let flexbox_10;
    let flexbox_11;
    let flexbox_12;
    let flexbox_13;
    let flexbox_14;
    let flexbox_15;
    let flexbox_16;
    let flexbox_17;
    let flexbox_18;
    let flexbox_19;
    let flexbox_20;
    let flexbox_21;
    let childFlexGrow025;
    let childFlexGrow025_1;
    let childFlexGrow025_2;
    let childFlexGrow025_3;
    let childFlexGrow025_4;
    let childFlexGrow025_5;
    let childFlexGrow025_6;
    let childFlexGrow025_7;
    let childFlexGrow025_8;
    let childFlexShrink05;
    let childFlexShrink05_1;
    let childFlexShrink05_2;
    let childFlexShrink05_3;
    let childFlexShrink05_4;
    let childFlexShrink05_5;
    let childFlexShrink05_6;
    let childFlexShrink05_7;
    let childFlexShrink05_8;
    let childFlexShrink025;
    let childFlexShrink025_1;
    let childFlexShrink025_2;
    let childFlexShrink025_3;
    let childFlexShrink025_4;
    let childFlexShrink025_5;
    let childFlexShrink025_6;
    let childFlexShrink025_7;
    let childFlexGrow075;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    flexbox = createElement(
      'div',
      {
        class: 'flexbox container',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05 = createElement('div', {
          class: 'child-flex-grow-0-5',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox container',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_1 = createElement('div', {
          class: 'child-flex-grow-0-5',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow025 = createElement('div', {
          class: 'child-flex-grow-0-25',
          'data-expected-width': '25',
          style: {
            'background-color': 'red',
            'flex-grow': '0.25',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox container column',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_2 = createElement('div', {
          class: 'child-flex-grow-0-5',
          'data-expected-height': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow025_1 = createElement('div', {
          class: 'child-flex-grow-0-25',
          'data-expected-height': '25',
          style: {
            'background-color': 'red',
            'flex-grow': '0.25',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        class: 'flexbox container column vertical',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_3 = createElement('div', {
          class: 'child-flex-grow-0-5 ',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow025_2 = createElement('div', {
          class: 'child-flex-grow-0-25 ',
          'data-expected-width': '25',
          style: {
            'background-color': 'red',
            'flex-grow': '0.25',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_4 = createElement(
      'div',
      {
        class: 'flexbox container vertical',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_4 = createElement('div', {
          class: 'child-flex-grow-0-5 ',
          'data-expected-height': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow025_3 = createElement('div', {
          class: 'child-flex-grow-0-25 ',
          'data-expected-height': '25',
          style: {
            'background-color': 'red',
            'flex-grow': '0.25',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_5 = createElement(
      'div',
      {
        class: 'flexbox container',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_5 = createElement('div', {
          class: 'child-flex-grow-0-5 basis',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'flex-basis': '30px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow025_4 = createElement('div', {
          class: 'child-flex-grow-0-25 basis',
          'data-expected-width': '40',
          style: {
            'background-color': 'red',
            'flex-grow': '0.25',
            'flex-basis': '30px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_6 = createElement(
      'div',
      {
        class: 'flexbox container column',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_6 = createElement('div', {
          class: 'child-flex-grow-0-5 basis',
          'data-expected-height': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'flex-basis': '30px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow025_5 = createElement('div', {
          class: 'child-flex-grow-0-25 basis',
          'data-expected-height': '40',
          style: {
            'background-color': 'red',
            'flex-grow': '0.25',
            'flex-basis': '30px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_7 = createElement(
      'div',
      {
        class: 'flexbox container vertical',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_7 = createElement('div', {
          class: 'child-flex-grow-0-5 basis',
          'data-expected-height': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'flex-basis': '30px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow025_6 = createElement('div', {
          class: 'child-flex-grow-0-25 basis',
          'data-expected-height': '40',
          style: {
            'background-color': 'red',
            'flex-grow': '0.25',
            'flex-basis': '30px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_8 = createElement(
      'div',
      {
        class: 'flexbox container column vertical',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_8 = createElement('div', {
          class: 'child-flex-grow-0-5 basis',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'flex-basis': '30px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow025_7 = createElement('div', {
          class: 'child-flex-grow-0-25 basis',
          'data-expected-width': '40',
          style: {
            'background-color': 'red',
            'flex-grow': '0.25',
            'flex-basis': '30px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_9 = createElement(
      'div',
      {
        class: 'flexbox container',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05 = createElement('div', {
          class: 'child-flex-shrink-0-5',
          'data-expected-width': '150',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_10 = createElement(
      'div',
      {
        class: 'flexbox container',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05_1 = createElement('div', {
          class: 'child-flex-shrink-0-5',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexShrink025 = createElement('div', {
          class: 'child-flex-shrink-0-25',
          'data-expected-width': '125',
          style: {
            'background-color': 'red',
            'flex-shrink': '0.25',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_11 = createElement(
      'div',
      {
        class: 'flexbox container column',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05_2 = createElement('div', {
          class: 'child-flex-shrink-0-5',
          'data-expected-height': '50',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexShrink025_1 = createElement('div', {
          class: 'child-flex-shrink-0-25',
          'data-expected-height': '125',
          style: {
            'background-color': 'red',
            'flex-shrink': '0.25',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_12 = createElement(
      'div',
      {
        class: 'flexbox container column vertical',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05_3 = createElement('div', {
          class: 'child-flex-shrink-0-5 ',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexShrink025_2 = createElement('div', {
          class: 'child-flex-shrink-0-25 ',
          'data-expected-width': '125',
          style: {
            'background-color': 'red',
            'flex-shrink': '0.25',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_13 = createElement(
      'div',
      {
        class: 'flexbox container vertical',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05_4 = createElement('div', {
          class: 'child-flex-shrink-0-5 ',
          'data-expected-height': '50',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexShrink025_3 = createElement('div', {
          class: 'child-flex-shrink-0-25 ',
          'data-expected-height': '125',
          style: {
            'background-color': 'red',
            'flex-shrink': '0.25',
            width: '200px',
            height: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_14 = createElement(
      'div',
      {
        class: 'flexbox container',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05_5 = createElement('div', {
          class: 'child-flex-shrink-0-5 basis-big',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexShrink025_4 = createElement('div', {
          class: 'child-flex-shrink-0-25 basis-big',
          'data-expected-width': '75',
          style: {
            'background-color': 'red',
            'flex-shrink': '0.25',
            width: '200px',
            height: '200px',
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_15 = createElement(
      'div',
      {
        class: 'flexbox container column',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05_6 = createElement('div', {
          class: 'child-flex-shrink-0-5 basis-big',
          'data-expected-height': '50',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexShrink025_5 = createElement('div', {
          class: 'child-flex-shrink-0-25 basis-big',
          'data-expected-height': '75',
          style: {
            'background-color': 'red',
            'flex-shrink': '0.25',
            width: '200px',
            height: '200px',
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_16 = createElement(
      'div',
      {
        class: 'flexbox container vertical',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05_7 = createElement('div', {
          class: 'child-flex-shrink-0-5 basis-big',
          'data-expected-height': '50',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexShrink025_6 = createElement('div', {
          class: 'child-flex-shrink-0-25 basis-big',
          'data-expected-height': '75',
          style: {
            'background-color': 'red',
            'flex-shrink': '0.25',
            width: '200px',
            height: '200px',
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_17 = createElement(
      'div',
      {
        class: 'flexbox container column vertical',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexShrink05_8 = createElement('div', {
          class: 'child-flex-shrink-0-5 basis-big',
          'data-expected-width': '50',
          style: {
            'background-color': 'green',
            'flex-shrink': '0.5',
            width: '200px',
            height: '200px',
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexShrink025_7 = createElement('div', {
          class: 'child-flex-shrink-0-25 basis-big',
          'data-expected-width': '75',
          style: {
            'background-color': 'red',
            'flex-shrink': '0.25',
            width: '200px',
            height: '200px',
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_18 = createElement(
      'div',
      {
        class: 'flexbox container',
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
          'background-color': 'red',
        },
      },
      [
        (childFlexGrow025_8 = createElement('div', {
          class: 'child-flex-grow-0-25 basis-0',
          'data-expected-width': '10',
          style: {
            'background-color': 'green',
            'flex-grow': '0.25',
            'flex-basis': '0',
            'box-sizing': 'border-box',
          },
        })),
        (childFlexGrow075 = createElement(
          'div',
          {
            class: 'child-flex-grow-0-75 basis-0',
            'data-expected-width': '90',
            style: {
              'background-color': 'lime',
              'flex-grow': '0.75',
              'flex-basis': '0',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '90px',
              },
            }),
          ]
        )),
      ]
    );
    flexbox_19 = createElement(
      'div',
      {
        class: 'flexbox container justify-content-center',
        style: {
          display: 'flex',
          '-webkit-justify-content': 'center',
          'justify-content': 'center',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_9 = createElement('div', {
          class: 'child-flex-grow-0-5',
          'data-expected-width': '50',
          'data-offset-x': '26',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_20 = createElement(
      'div',
      {
        class: 'flexbox container justify-content-space-around',
        style: {
          display: 'flex',
          '-webkit-justify-content': 'space-around',
          'justify-content': 'space-around',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_10 = createElement('div', {
          class: 'child-flex-grow-0-5',
          'data-expected-width': '50',
          'data-offset-x': '26',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_21 = createElement(
      'div',
      {
        class: 'flexbox container justify-content-flex-end',
        style: {
          display: 'flex',
          '-webkit-justify-content': 'flex-end',
          'justify-content': 'flex-end',
          height: '100px',
          width: '100px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        (childFlexGrow05_11 = createElement('div', {
          class: 'child-flex-grow-0-5',
          'data-expected-width': '50',
          'data-offset-x': '51',
          style: {
            'background-color': 'green',
            'flex-grow': '0.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);
    BODY.appendChild(flexbox_2);
    BODY.appendChild(flexbox_3);
    BODY.appendChild(flexbox_4);
    BODY.appendChild(flexbox_5);
    BODY.appendChild(flexbox_6);
    BODY.appendChild(flexbox_7);
    BODY.appendChild(flexbox_8);
    BODY.appendChild(flexbox_9);
    BODY.appendChild(flexbox_10);
    BODY.appendChild(flexbox_11);
    BODY.appendChild(flexbox_12);
    BODY.appendChild(flexbox_13);
    BODY.appendChild(flexbox_14);
    BODY.appendChild(flexbox_15);
    BODY.appendChild(flexbox_16);
    BODY.appendChild(flexbox_17);
    BODY.appendChild(flexbox_18);
    BODY.appendChild(flexbox_19);
    BODY.appendChild(flexbox_20);
    BODY.appendChild(flexbox_21);

    await snapshot();
  });
});
