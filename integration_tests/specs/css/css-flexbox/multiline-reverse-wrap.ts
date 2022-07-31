/*auto generated*/
describe('multiline-reverse', () => {
  xit('wrap-baseline', async () => {
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '200px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'align-items': 'baseline',
          'margin-bottom': '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightblue',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [
            createText(`first`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`first`),
            createElement('br', {
              style: {
                'background-color': 'lightgreen',
                'box-sizing': 'border-box',
              },
            }),
            createText(`first`),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightgreen',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [createText(`second`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'pink',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
              'margin-top': '5px',
            },
          },
          [createText(`third`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'yellow',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [
            createText(`fourth`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`fourth`),
          ]
        ),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '200px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'align-items': 'baseline',
          'margin-bottom': '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightblue',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [
            createText(`first`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`first`),
            createElement('br', {
              style: {
                'background-color': 'lightgreen',
                'box-sizing': 'border-box',
              },
            }),
            createText(`first`),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightgreen',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [createText(`second`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'pink',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [createText(`third`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'yellow',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
              'margin-bottom': '5px',
            },
          },
          [
            createText(`fourth`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`fourth`),
          ]
        ),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '300px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'align-items': 'baseline',
          'margin-bottom': '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightblue',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
              'align-self': 'flex-start',
              height: '100px',
            },
          },
          [createText(`first`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightgreen',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [createText(`second`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'pink',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [
            createText(`third`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`third`),
          ]
        ),
      ]
    );
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);
    BODY.appendChild(flexbox_2);

    await matchViewportSnapshot();
  });
  it('wrap-overflow', async () => {
    let log;
    let p;
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    let flexbox_3;
    let flexbox_4;
    let flexbox_5;
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
        createText(`Test to make sure that wrap-reverse starts at the cross start edge if
sizing is not auto.`),
      ]
    );
    flexbox = createElement(
      'div',
      {
        'data-expected-width': '200',
        'data-expected-height': '35',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          width: '200px',
          height: '35px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '15',
          style: {
            border: '0',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '100',
          'data-offset-y': '25',
          style: {
            border: '0',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '5',
          style: {
            border: '0',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '100',
          'data-offset-y': '-5',
          style: {
            border: '0',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '20px',
          },
        }),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        'data-expected-width': '200',
        'data-expected-height': '35',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          width: '200px',
          'max-height': '35px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '15',
          style: {
            border: '0',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '100',
          'data-offset-y': '25',
          style: {
            border: '0',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '5',
          style: {
            border: '0',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '100',
          'data-offset-y': '-5',
          style: {
            border: '0',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            flex: '1 100px',
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
          'flex-wrap': 'wrap-reverse',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          width: '200px',
          'min-height': '50px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '30',
          style: {
            border: '0',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '100',
          'data-offset-y': '40',
          style: {
            border: '0',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '20',
          style: {
            border: '0',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '100',
          'data-offset-y': '10',
          style: {
            border: '0',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            flex: '1 100px',
            height: '20px',
          },
        }),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        'data-expected-width': '35',
        'data-expected-height': '200',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          'flex-direction': 'column',
          height: '200px',
          width: '35px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '15',
          'data-offset-y': '0',
          style: {
            border: '0',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '25',
          'data-offset-y': '100',
          style: {
            border: '0',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '5',
          'data-offset-y': '0',
          style: {
            border: '0',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '-5',
          'data-offset-y': '100',
          style: {
            border: '0',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '20px',
          },
        }),
      ]
    );
    flexbox_4 = createElement(
      'div',
      {
        'data-expected-width': '35',
        'data-expected-height': '200',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          'flex-direction': 'column',
          height: '200px',
          'max-width': '35px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '15',
          'data-offset-y': '0',
          style: {
            border: '0',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '25',
          'data-offset-y': '100',
          style: {
            border: '0',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '5',
          'data-offset-y': '0',
          style: {
            border: '0',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '-5',
          'data-offset-y': '100',
          style: {
            border: '0',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '20px',
          },
        }),
      ]
    );
    flexbox_5 = createElement(
      'div',
      {
        'data-expected-width': '600',
        'data-expected-height': '200',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'margin-top': '20px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          'flex-direction': 'column',
          height: '200px',
          'min-width': '50px',
          'max-width': '600px',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '580',
          'data-offset-y': '0',
          style: {
            border: '0',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '590',
          'data-offset-y': '100',
          style: {
            border: '0',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '570',
          'data-offset-y': '0',
          style: {
            border: '0',
            'background-color': 'pink',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '10px',
          },
        }),
        createElement('div', {
          'data-offset-x': '560',
          'data-offset-y': '100',
          style: {
            border: '0',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            flex: '1 100px',
            width: '20px',
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
    BODY.appendChild(flexbox_4);
    BODY.appendChild(flexbox_5);

    await matchViewportSnapshot();
  });
});
