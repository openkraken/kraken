/*auto generated*/
describe('multiline-column', () => {
  it('max-height', async () => {
    let item;
    let item_1;
    let item_2;
    let item_3;
    let item_4;
    let item_5;
    let item_6;
    let item_7;
    let item_8;
    let item_9;
    let item_10;
    let item_11;
    let item_12;
    let item_13;
    let item_14;
    let item_15;
    let flex;
    flex = createElement(
      'div',
      {
        class: 'flex',
        style: {
          display: 'flex',
          'flex-flow': 'column wrap',
          'max-height': '200px',
          background: 'blue',
          'box-sizing': 'border-box',
        },
      },
      [
        (item = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 1`)]
        )),
        (item_1 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 2`)]
        )),
        (item_2 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 3`)]
        )),
        (item_3 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 4`)]
        )),
        (item_4 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 5`)]
        )),
        (item_5 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 6`)]
        )),
        (item_6 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 7`)]
        )),
        (item_7 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 8`)]
        )),
        (item_8 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 9`)]
        )),
        (item_9 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 10`)]
        )),
        (item_10 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 11`)]
        )),
        (item_11 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 12`)]
        )),
        (item_12 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 13`)]
        )),
        (item_13 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 14`)]
        )),
        (item_14 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 15`)]
        )),
        (item_15 = createElement(
          'span',
          {
            class: 'item',
            style: {
              flex: '0 0 auto',
              'line-height': '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`FAIL 16`)]
        )),
      ]
    );
    BODY.appendChild(flex);

    await snapshot();
  });

  it('auto', async () => {
    let log;
    let p;
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    let flexbox_3;
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
      [
        createText(
          `Test to make sure that multiline columns break at the right places when auto sized.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        'data-expected-width': '200',
        'data-expected-height': '80',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          width: '200px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '20',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '40',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '60',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        'data-expected-width': '200',
        'data-expected-height': '40',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          width: '200px',
          'max-height': '50px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '20',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '50',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '50',
          'data-offset-y': '20',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        'data-expected-width': '200',
        'data-expected-height': '50',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          width: '200px',
          height: '50px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '20',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '50',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '50',
          'data-offset-y': '20',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        'data-expected-width': '200',
        'data-expected-height': '30',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          width: '200px',
          height: '50px',
          'max-height': '30px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '50',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '100',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '150',
          'data-offset-y': '0',
          style: {
            border: '0',
            flex: 'none',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            width: '50px',
            height: '20px',
          },
        }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(p);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);
    BODY.appendChild(flexbox_2);
    BODY.appendChild(flexbox_3);

    await matchViewportSnapshot();
  });
});
