/*auto generated*/
describe('flex-align', () => {
  it('items-center', async () => {
    let failFlag;
    let container;
    failFlag = createElement('div', {
      id: 'fail-flag',
      style: {
        position: 'absolute',
        top: '162px',
        left: '272px',
        width: '92px',
        height: '36px',
        'background-color': 'red',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'center',
          'align-items': 'center',
          border: '5px solid green',
          width: '400px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            border: '2px solid blue',
            'background-color': 'green',
            'border-radius': '3px',
            padding: '10px',
            width: '30px',
            height: '40px',
            'text-align': 'center',
            flex: 'none',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '2px solid blue',
            'background-color': 'green',
            'border-radius': '3px',
            padding: '10px',
            width: '30px',
            height: '40px',
            'text-align': 'center',
            flex: 'none',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '2px solid blue',
            'background-color': 'green',
            'border-radius': '3px',
            padding: '10px',
            width: '30px',
            height: '40px',
            'text-align': 'center',
            flex: 'none',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(failFlag);
    BODY.appendChild(container);

    await snapshot();
  });

  it('item-center space-around', async () => {
    let failFlag;
    let container;
    failFlag = createElement('div', {
      id: 'fail-flag',
      style: {
        position: 'absolute',
        top: '162px',
        left: '272px',
        width: '92px',
        height: '36px',
        'background-color': 'red',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
        'div',
        {
          id: 'container',
          style: {
            display: 'flex',
            'justify-content': 'space-between',
            'align-items': 'center',
            border: '5px solid green',
            width: '400px',
            height: '200px',
            padding: '50px',
            'border-radius': '3px',
            position: 'absolute',
            top: '70px',
            left: '10px',
            'box-sizing': 'border-box',
          },
        },
        [
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),

        ]
    );
    BODY.appendChild(failFlag);
    BODY.appendChild(container);

    await snapshot();
  });

  it('align-items start', async () => {
    let failFlag;
    let container;
    failFlag = createElement('div', {
      id: 'fail-flag',
      style: {
        position: 'absolute',
        top: '162px',
        left: '272px',
        width: '92px',
        height: '36px',
        'background-color': 'red',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
        'div',
        {
          id: 'container',
          style: {
            display: 'flex',
            'justify-content': 'space-evenly',
            'align-items': 'start',
            border: '5px solid green',
            width: '400px',
            height: '200px',
            padding: '50px',
            'border-radius': '3px',
            position: 'absolute',
            top: '70px',
            left: '10px',
            'box-sizing': 'border-box',
          },
        },
        [
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),

        ]
    );
    BODY.appendChild(failFlag);
    BODY.appendChild(container);

    await snapshot();
  });

  it('align-items flex-end', async () => {
    let failFlag;
    let container;
    failFlag = createElement('div', {
      id: 'fail-flag',
      style: {
        position: 'absolute',
        top: '162px',
        left: '272px',
        width: '92px',
        height: '36px',
        'background-color': 'red',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
        'div',
        {
          id: 'container',
          style: {
            display: 'flex',
            'justify-content': 'space-evenly',
            'align-items': 'flex-end',
            border: '5px solid green',
            width: '400px',
            height: '200px',
            padding: '50px',
            'border-radius': '3px',
            position: 'absolute',
            top: '70px',
            left: '10px',
            'box-sizing': 'border-box',
          },
        },
        [
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),
          createElement('div', {
            style: {
              border: '2px solid blue',
              'background-color': 'green',
              'border-radius': '3px',
              padding: '10px',
              width: '30px',
              height: '40px',
              'text-align': 'center',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          }),

        ]
    );
    BODY.appendChild(failFlag);
    BODY.appendChild(container);

    await snapshot();
  });

  it('column', async () => {
    let log;
    let flexbox;
    let flexbox_1;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    flexbox = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          width: '600px',
          height: '240px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-expected-width': '600',
          'data-expected-height': '40',
          style: {
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-expected-width': '600',
          'data-expected-height': '40',
          style: {
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'stretch',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-expected-width': '20',
          'data-expected-height': '40',
          style: {
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'flex-start',
            width: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '580',
          'data-expected-width': '20',
          'data-expected-height': '40',
          style: {
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'flex-end',
            width: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '290',
          'data-expected-width': '20',
          'data-expected-height': '40',
          style: {
            'background-color': 'purple',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'center',
            width: '20px',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-expected-width': '20',
          'data-expected-height': '40',
          style: {
            'background-color': 'orange',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'baseline',
            width: '20px',
          },
        }),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column vertical',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          width: '600px',
          height: '240px',
          'background-color': '#aaa',
          position: 'relative',
          'writing-mode': 'vertical-lr',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-offset-y': '0',
          'data-expected-width': '100',
          'data-expected-height': '240',
          style: {
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1',
          },
        }),
        createElement('div', {
          'data-offset-y': '0',
          'data-expected-width': '100',
          'data-expected-height': '240',
          style: {
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'stretch',
          },
        }),
        createElement('div', {
          'data-offset-y': '0',
          'data-expected-width': '100',
          'data-expected-height': '20',
          style: {
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'flex-start',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-y': '220',
          'data-expected-width': '100',
          'data-expected-height': '20',
          style: {
            'background-color': 'yellow',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'flex-end',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-y': '110',
          'data-expected-width': '100',
          'data-expected-height': '20',
          style: {
            'background-color': 'purple',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'center',
            height: '20px',
          },
        }),
        createElement('div', {
          'data-offset-y': '0',
          'data-expected-width': '100',
          'data-expected-height': '20',
          style: {
            'background-color': 'orange',
            'box-sizing': 'border-box',
            flex: '1',
            'align-self': 'baseline',
            height: '20px',
          },
        }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);

    await matchViewportSnapshot();
  });
  it('max', async () => {
    let log;
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
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '50',
          style: {
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 0 0',
            'max-height': '100px',
          },
        }),
        createElement('div', {
          'data-expected-height': '50',
          style: {
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 0 0',
            height: '50px',
          },
        }),
        createElement('div', {
          'data-expected-height': '25',
          style: {
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1 0 0',
            'max-height': '25px',
          },
        }),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          width: '200px',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '150',
          style: {
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 0 20px',
            'max-width': '150px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          style: {
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 0 20px',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          style: {
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1 0 20px',
          },
        }),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox vertical-rl',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
          height: '60px',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          style: {
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 0 20px',
            'max-width': '110px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          style: {
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 0 20px',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '50',
          style: {
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1 0 20px',
            'max-width': '50px',
          },
        }),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        class: 'flexbox column vertical-rl',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          'background-color': '#aaa',
          position: 'relative',
          'writing-mode': 'vertical-rl',
          'box-sizing': 'border-box',
          height: '50px',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '50',
          style: {
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 0 100px',
            'max-height': '100px',
          },
        }),
        createElement('div', {
          'data-expected-height': '50',
          style: {
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 0 100px',
            height: '50px',
          },
        }),
        createElement('div', {
          'data-expected-height': '25',
          style: {
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1 0 100px',
            'max-height': '25px',
          },
        }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);
    BODY.appendChild(flexbox_2);
    BODY.appendChild(flexbox_3);

    await matchViewportSnapshot();
  });
  it('percent-height', async () => {
    let log;
    let flexOne;
    let flexOne_1;
    let flexbox;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          height: '50%',
        },
      },
      [
        (flexOne = createElement('div', {
          'data-expected-height': '50',
          'data-offset-y': '0',
          class: 'flex-one',
          style: {
            '-webkit-flex': '1',
            flex: '1',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            height: '50px',
          },
        })),
        (flexOne_1 = createElement('div', {
          'data-expected-height': '300',
          'data-offset-y': '0',
          class: 'flex-one',
          style: {
            '-webkit-flex': '1',
            flex: '1',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);

    BODY.style.height = '600px';

    await matchViewportSnapshot();
  });
  it('stretch', async () => {
    let log;
    let absolute;
    let absolute_1;
    let absolute_2;
    let absolute_3;
    let absolute_4;
    let absolute_5;
    let flexOne;
    let flexOne_1;
    let flexOne_2;
    let flexOne_3;
    let flexOne_4;
    let flexOne_5;
    let flexOne_6;
    let flexOne_7;
    let flexOne_8;
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    let flexbox_3;
    let flexbox_4;
    let div;
    let div_1;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          width: '600px',
        },
      },
      [
        (flexOne = createElement(
          'div',
          {
            'data-expected-height': '100',
            class: 'flex-one',
            style: {
              '-webkit-flex': '1',
              flex: '1',
              border: '0',
              'background-color': 'blue',
              'box-sizing': 'border-box',
              position: 'relative',
            },
          },
          [
            (absolute = createElement('div', {
              'data-offset-x': '0',
              'data-offset-y': '50',
              class: 'absolute',
              style: {
                border: '0',
                position: 'absolute',
                width: '50px',
                height: '50px',
                'background-color': 'yellow',
                'box-sizing': 'border-box',
                bottom: '0',
              },
            })),
          ]
        )),
        (flexOne_1 = createElement('div', {
          'data-expected-height': '100',
          class: 'flex-one',
          style: {
            '-webkit-flex': '1',
            flex: '1',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            height: '100px',
          },
        })),
        (flexOne_2 = createElement(
          'div',
          {
            'data-expected-height': '100',
            class: 'flex-one',
            style: {
              '-webkit-flex': '1',
              flex: '1',
              border: '0',
              'background-color': 'red',
              'box-sizing': 'border-box',
              position: 'relative',
            },
          },
          [
            (absolute_1 = createElement('div', {
              'data-offset-x': '0',
              'data-offset-y': '50',
              class: 'absolute',
              style: {
                border: '0',
                position: 'absolute',
                width: '50px',
                height: '50px',
                'background-color': 'yellow',
                'box-sizing': 'border-box',
                bottom: '0',
              },
            })),
          ]
        )),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'writing-mode': 'vertical-rl',
        },
      },
      [
        (flexbox_1 = createElement(
          'div',
          {
            class: 'flexbox',
            style: {
              display: 'flex',
              'background-color': '#aaa',
              position: 'relative',
              'box-sizing': 'border-box',
              height: '200px',
            },
          },
          [
            (flexOne_3 = createElement(
              'div',
              {
                'data-expected-width': '100',
                class: 'flex-one',
                style: {
                  '-webkit-flex': '1',
                  flex: '1',
                  border: '0',
                  'background-color': 'blue',
                  'box-sizing': 'border-box',
                  position: 'relative',
                },
              },
              [
                (absolute_2 = createElement('div', {
                  'data-offset-x': '0',
                  'data-offset-y': '0',
                  class: 'absolute',
                  style: {
                    border: '0',
                    position: 'absolute',
                    width: '50px',
                    height: '50px',
                    'background-color': 'yellow',
                    'box-sizing': 'border-box',
                    left: '0',
                  },
                })),
              ]
            )),
            (flexOne_4 = createElement('div', {
              'data-expected-width': '100',
              class: 'flex-one',
              style: {
                '-webkit-flex': '1',
                flex: '1',
                border: '0',
                'background-color': 'green',
                'box-sizing': 'border-box',
                width: '100px',
              },
            })),
            (flexOne_5 = createElement(
              'div',
              {
                'data-expected-width': '100',
                class: 'flex-one',
                style: {
                  '-webkit-flex': '1',
                  flex: '1',
                  border: '0',
                  'background-color': 'red',
                  'box-sizing': 'border-box',
                  position: 'relative',
                },
              },
              [
                (absolute_3 = createElement('div', {
                  'data-offset-x': '0',
                  'data-offset-y': '0',
                  class: 'absolute',
                  style: {
                    border: '0',
                    position: 'absolute',
                    width: '50px',
                    height: '50px',
                    'background-color': 'yellow',
                    'box-sizing': 'border-box',
                    left: '0',
                  },
                })),
              ]
            )),
          ]
        )),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'writing-mode': 'vertical-lr',
        },
      },
      [
        (flexbox_2 = createElement(
          'div',
          {
            class: 'flexbox',
            style: {
              display: 'flex',
              'background-color': '#aaa',
              position: 'relative',
              'box-sizing': 'border-box',
              height: '200px',
            },
          },
          [
            (flexOne_6 = createElement(
              'div',
              {
                'data-expected-width': '100',
                class: 'flex-one',
                style: {
                  '-webkit-flex': '1',
                  flex: '1',
                  border: '0',
                  'background-color': 'blue',
                  'box-sizing': 'border-box',
                  position: 'relative',
                },
              },
              [
                (absolute_4 = createElement('div', {
                  'data-offset-x': '50',
                  'data-offset-y': '0',
                  class: 'absolute',
                  style: {
                    border: '0',
                    position: 'absolute',
                    width: '50px',
                    height: '50px',
                    'background-color': 'yellow',
                    'box-sizing': 'border-box',
                    right: '0',
                  },
                })),
              ]
            )),
            (flexOne_7 = createElement('div', {
              'data-expected-width': '100',
              class: 'flex-one',
              style: {
                '-webkit-flex': '1',
                flex: '1',
                border: '0',
                'background-color': 'green',
                'box-sizing': 'border-box',
                width: '100px',
              },
            })),
            (flexOne_8 = createElement(
              'div',
              {
                'data-expected-width': '100',
                class: 'flex-one',
                style: {
                  '-webkit-flex': '1',
                  flex: '1',
                  border: '0',
                  'background-color': 'red',
                  'box-sizing': 'border-box',
                  position: 'relative',
                },
              },
              [
                (absolute_5 = createElement('div', {
                  'data-offset-x': '0',
                  'data-offset-y': '0',
                  class: 'absolute',
                  style: {
                    border: '0',
                    position: 'absolute',
                    width: '50px',
                    height: '50px',
                    'background-color': 'yellow',
                    'box-sizing': 'border-box',
                    left: '0',
                  },
                })),
              ]
            )),
          ]
        )),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          height: '50px',
          width: '600px',
        },
      },
      [
        createElement(
          'div',
          {
            'data-expected-height': '50',
            style: {
              border: '0',
              'background-color': 'yellow',
              'box-sizing': 'border-box',
              width: '300px',
            },
          },
          [
            createElement('div', {
              'data-expected-height': '60',
              style: {
                border: '0',
                'box-sizing': 'border-box',
                height: '60px',
                width: '10px',
                'background-color': 'orange',
              },
            }),
          ]
        ),
      ]
    );
    flexbox_4 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          width: '100px',
        },
      },
      [
        createElement(
          'div',
          {
            'data-expected-width': '100',
            'data-expected-height': '50',
            style: {
              border: '0',
              'background-color': 'yellow',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              'data-expected-width': '200',
              style: {
                border: '0',
                'box-sizing': 'border-box',
                height: '50px',
                width: '200px',
                'background-color': 'orange',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);
    BODY.appendChild(flexbox_2);
    BODY.appendChild(flexbox_3);
    BODY.appendChild(flexbox_4);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await matchViewportSnapshot();
  });
});
