/*auto generated*/
describe('flex-algorithm', () => {
  it('min-max', async () => {
    let log;
    let flex100;
    let flex100_1;
    let flex100_2;
    let flex100_3;
    let flex100_4;
    let flex100_5;
    let flex100_6;
    let flex100_7;
    let flex100_8;
    let flex100_9;
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
    let flex1;
    let flex1_1;
    let flex1_2;
    let flex1_3;
    let flex1_4;
    let flex1_5;
    let flex1_6;
    let flex3;
    let flex2;
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
        },
      },
      [
        (flex100 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        })),
        (flex100_1 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
        (flex100_2 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_3 = createElement('div', {
          'data-expected-width': '50',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            'max-width': '50px',
          },
        })),
        createElement('div', {
          'data-expected-width': '300',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '4 0 0',
            'max-width': '300px',
          },
        }),
        createElement('div', {
          'data-expected-width': '250',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1 0 0',
          },
        }),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_4 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        })),
        createElement('div', {
          'data-expected-width': '300',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 0 200px',
            'max-width': '300px',
          },
        }),
        (flex100_5 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '350',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 400px',
            'min-width': '350px',
          },
        }),
        createElement('div', {
          'data-expected-width': '250',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 1 400px',
          },
        }),
      ]
    );
    flexbox_4 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '350',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 400px',
            'min-width': '350px',
          },
        }),
        createElement('div', {
          'data-expected-width': '300',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '2 0 300px',
            'max-width': '300px',
          },
        }),
        (flex100_6 = createElement('div', {
          'data-expected-width': '0',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_5 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_7 = createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '0',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            margin: '0 auto',
            'max-width': '100px',
          },
        })),
        createElement('div', {
          'data-expected-width': '333',
          'data-offset-x': '100',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '2 0 0',
          },
        }),
        (flex100_8 = createElement('div', {
          'data-expected-width': '167',
          'data-offset-x': '433',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_6 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_9 = createElement('div', {
          'data-expected-width': '500',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            'min-width': '300px',
          },
        })),
        createElement('div', {
          'data-expected-width': '100',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 0 50%',
            'max-width': '100px',
          },
        }),
      ]
    );
    flexbox_7 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '200px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1 = createElement('div', {
          'data-expected-width': '150',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
            'min-width': '150px',
          },
        })),
        (flex1_1 = createElement('div', {
          'data-expected-width': '50',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1',
            'box-sizing': 'border-box',
            'max-width': '90px',
          },
        })),
      ]
    );
    flexbox_8 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '200px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_2 = createElement('div', {
          'data-expected-width': '150',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
            'min-width': '120px',
          },
        })),
        (flex1_3 = createElement('div', {
          'data-expected-width': '50',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1',
            'box-sizing': 'border-box',
            'max-width': '50px',
          },
        })),
      ]
    );
    flexbox_9 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '200px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_4 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
            'min-width': '100px',
          },
        })),
        (flex3 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex3',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '3',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_10 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '200px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '150',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 50px',
            'min-width': '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '50',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 100px',
            'max-width': '50px',
          },
        }),
      ]
    );
    flexbox_11 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_5 = createElement('div', {
          'data-expected-width': '80',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (flex2 = createElement('div', {
          'data-expected-width': '160',
          class: 'flex2',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '2',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_6 = createElement('div', {
          'data-expected-width': '360',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1',
            'box-sizing': 'border-box',
            'min-width': '360px',
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

    await matchViewportSnapshot();
  });
  it('with-margins', async () => {
    let log;
    let flex100;
    let flex100_1;
    let flex100_2;
    let flex100_3;
    let flex100_4;
    let flex100_5;
    let flex100_6;
    let flex100_7;
    let flex100_8;
    let flex100_9;
    let flexNone;
    let flexNone_1;
    let flexNone_2;
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
    let flex4;
    let flex1;
    let flex1_1;
    let flex200;
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
        },
      },
      [
        (flex100 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
        (flexNone = createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '250',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
            margin: '0 50px',
          },
        })),
        (flex100_1 = createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '400',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        'data-expected-height': '120',
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_2 = createElement('div', {
          'data-expected-width': '200',
          'data-offset-y': '50',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            margin: '50px 0',
          },
        })),
        (flexNone_1 = createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '250',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
            margin: '0 50px',
          },
        })),
        (flex100_3 = createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '400',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_4 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
        (flexNone_2 = createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '200',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '200px',
            margin: '0 auto',
          },
        })),
        (flex100_5 = createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '400',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_6 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          'data-expected-width': '300',
          'data-offset-x': '100',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '2 0 100px',
            'margin-left': 'auto',
          },
        }),
        (flex100_7 = createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '400',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            'margin-right': '100px',
          },
        })),
      ]
    );
    flexbox_4 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '150',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 300px',
          },
        }),
        createElement('div', {
          'data-expected-width': '300',
          'data-offset-x': '150',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 0 300px',
            margin: '0 auto',
          },
        }),
        createElement('div', {
          'data-expected-width': '150',
          'data-offset-x': '450',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1 1 300px',
          },
        }),
      ]
    );
    flexbox_5 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '300',
          'data-offset-x': '150',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '0 0 300px',
            margin: '0 auto',
          },
        }),
      ]
    );
    flexbox_6 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '700',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '0 0 700px',
            margin: '0 auto',
          },
        }),
      ]
    );
    flexbox_7 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '600',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 0 300px',
            margin: '0 auto',
          },
        }),
      ]
    );
    flexbox_8 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex4 = createElement(
          'div',
          {
            'data-expected-width': '600',
            'data-offset-x': '0',
            class: 'flex4',
            style: {
              height: '20px',
              border: '0',
              'background-color': 'blue',
              flex: '4',
              'box-sizing': 'border-box',
              margin: '0 auto',
            },
          },
          [
            createElement('div', {
              style: {
                height: '100%',
                border: '0',
                'background-color': 'blue',
                'box-sizing': 'border-box',
                width: '100px',
              },
            }),
          ]
        )),
      ]
    );
    flexbox_9 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          margin: '100px',
        },
      },
      [
        (flex1 = createElement('div', {
          'data-expected-width': '300',
          'data-offset-x': '0',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
            margin: '0 auto',
          },
        })),
        (flex1_1 = createElement('div', {
          'data-expected-width': '300',
          'data-offset-x': '300',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1',
            'box-sizing': 'border-box',
            margin: '0 auto',
          },
        })),
      ]
    );
    flexbox_10 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          padding: '100px',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '300',
          'data-offset-x': '100',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 0 0px',
            margin: '0 auto',
          },
        }),
        createElement('div', {
          'data-expected-width': '300',
          'data-offset-x': '400',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 0 0px',
            margin: '0 auto',
          },
        }),
      ]
    );
    flexbox_11 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_8 = createElement('div', {
          'data-expected-width': '75',
          'data-offset-x': '0',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            margin: '0 auto',
          },
        })),
        (flex200 = createElement('div', {
          'data-expected-width': '350',
          'data-offset-x': '75',
          class: 'flex2-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '2 0 0px',
            'box-sizing': 'border-box',
            padding: '0 100px',
          },
        })),
        (flex100_9 = createElement('div', {
          'data-expected-width': '75',
          'data-offset-x': '525',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            'margin-left': '100px',
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

    await matchViewportSnapshot();
  });

  it('algorithm', async () => {
    let log;
    let flex1;
    let flex1_1;
    let flex1_2;
    let flex1_3;
    let flex1_4;
    let flex1_5;
    let flex1_6;
    let flex1_7;
    let flex1_8;
    let flex1_9;
    let flex1_10;
    let flex1_11;
    let flex1_12;
    let flex1_13;
    let flex1_14;
    let flex1_15;
    let flex1_16;
    let flex1_17;
    let flex1_18;
    let flex1_19;
    let flex1_20;
    let flex1_21;
    let flex1_22;
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
    let flexbox_22;
    let flexbox_23;
    let flexbox_24;
    let flexbox_25;
    let flex3;
    let flex3_1;
    let flex2;
    let flex2_1;
    let flex2_2;
    let flex2_3;
    let flex2_4;
    let flex2_5;
    let flexNone;
    let flexNone_1;
    let flexNone_2;
    let flexNone_3;
    let flexNone_4;
    let flexNone_5;
    let flexNone_6;
    let flexNone_7;
    let flex100;
    let flex100_1;
    let flex100_2;
    let flex100_3;
    let flex100_4;
    let flexAuto;
    let flexAuto_1;
    let flexAuto_2;
    let div;
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
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_1 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_2 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '200',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '.5',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '.5',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '.5',
          },
        }),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex3 = createElement('div', {
          'data-expected-width': '300',
          class: 'flex3',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '3',
            'box-sizing': 'border-box',
          },
        })),
        (flex2 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex2',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '2',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_3 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_4 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_5 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (flexNone = createElement('div', {
          'data-expected-width': '100',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        })),
      ]
    );
    flexbox_4 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_6 = createElement('div', {
          'data-expected-width': '150',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_7 = createElement('div', {
          'data-expected-width': '150',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (flexNone_1 = createElement('div', {
          'data-expected-width': '300',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '50%',
          },
        })),
      ]
    );
    flexbox_5 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_8 = createElement('div', {
          'data-expected-width': '150',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          'data-expected-width': '350',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 200px',
          },
        }),
        (flexNone_2 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        })),
      ]
    );
    flexbox_6 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_9 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          'data-expected-width': '400',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '2 33.333333%',
          },
        }),
        (flexNone_3 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        })),
      ]
    );
    flexbox_7 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '200',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 300px',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '2 1 300px',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '3 1 300px',
          },
        }),
      ]
    );
    flexbox_8 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '250',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 300px',
          },
        }),
        createElement('div', {
          'data-expected-width': '150',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '2 3 300px',
          },
        }),
        (flexNone_4 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '200px',
          },
        })),
      ]
    );
    flexbox_9 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '50',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '250',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 1 500px',
          },
        }),
        (flexNone_5 = createElement('div', {
          'data-expected-width': '300',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '300px',
          },
        })),
      ]
    );
    flexbox_10 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '50',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '250',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 1 500px',
            'margin-right': '300px',
          },
        }),
      ]
    );
    flexbox_11 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '50',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '550',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 1 500px',
            'padding-left': '300px',
          },
        }),
      ]
    );
    flexbox_12 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '50',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '1 1 100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '550',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '1 1 500px',
            'border-left': '200px dashed orange',
            'border-right': '100px dashed orange',
          },
        }),
      ]
    );
    flexbox_13 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '600',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '0 100000000000000000000000000000000000000 600px',
          },
        }),
        createElement('div', {
          'data-expected-width': '600',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '0 100000000000000000000000000000000000000 600px',
          },
        }),
      ]
    );
    flexbox_14 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '600',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '100000000000000000000000000000000000000 0 600px',
          },
        }),
        createElement('div', {
          'data-expected-width': '600',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '0 100000000000000000000000000000000000000 600px',
          },
        }),
        createElement('div', {
          'data-expected-width': '33554428',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            flex: '1 1 100000000000000000000000000000000000000px',
          },
        }),
      ]
    );
    flexbox_15 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_10 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
            'border-left': '150px solid black',
          },
        })),
        (flex100 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            'border-right': '150px solid orange',
          },
        })),
        (flex100_1 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_16 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '300',
          style: {
            height: '20px',
            border: '100px solid black',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            width: '100px',
            flex: 'none',
          },
        }),
        (flex2_1 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex2',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '2',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_11 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_17 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_12 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
            'padding-left': '150px',
          },
        })),
        (flex100_2 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
            'padding-right': '150px',
          },
        })),
        (flex100_3 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1-0-0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1 0 0px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_18 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexNone_6 = createElement('div', {
          'data-expected-width': '300',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            width: '100px',
            padding: '100px',
          },
        })),
        (flex2_2 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex2',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '2',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_13 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_19 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_14 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
            'padding-left': '25%',
          },
        })),
        (flex3_1 = createElement('div', {
          'data-expected-width': '150',
          class: 'flex3',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '3',
            'box-sizing': 'border-box',
          },
        })),
        (flexNone_7 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex-none',
          style: {
            '-webkit-flex': 'none',
            flex: 'none',
            height: '20px',
            border: '0',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
            'padding-right': '25%',
          },
        })),
      ]
    );
    flexbox_20 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_15 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            flex: '1',
            'box-sizing': 'border-box',
            'padding-left': '50px',
            'border-right': '50px solid black',
          },
        })),
        (flex2_3 = createElement('div', {
          'data-expected-width': '250',
          class: 'flex2',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '2',
            'box-sizing': 'border-box',
            'border-right': '50px solid orange',
          },
        })),
        (flex1_16 = createElement('div', {
          'data-expected-width': '150',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1',
            'box-sizing': 'border-box',
            'padding-right': '50px',
          },
        })),
      ]
    );
    flexbox_21 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex1_17 = createElement(
          'div',
          {
            'data-expected-width': '120',
            class: 'flex1',
            style: {
              height: '20px',
              border: '0',
              'background-color': 'blue',
              flex: '1',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                height: '100%',
                border: '0',
                'background-color': 'blue',
                'box-sizing': 'border-box',
                width: '100px',
              },
            }),
          ]
        )),
        (flex2_4 = createElement('div', {
          'data-expected-width': '240',
          class: 'flex2',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '2',
            'box-sizing': 'border-box',
          },
        })),
        (flex2_5 = createElement('div', {
          'data-expected-width': '240',
          class: 'flex2',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '2',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_22 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex100_4 = createElement(
          'div',
          {
            'data-expected-width': '200',
            class: 'flex1-0-0',
            style: {
              height: '20px',
              border: '0',
              'background-color': 'blue',
              flex: '1 0 0px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                height: '100%',
                border: '0',
                'background-color': 'blue',
                'box-sizing': 'border-box',
                width: '100px',
              },
            }),
          ]
        )),
        (flex1_18 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (flex1_19 = createElement('div', {
          'data-expected-width': '200',
          class: 'flex1',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'red',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    flexbox_23 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexAuto = createElement(
          'div',
          {
            'data-expected-width': '200',
            class: 'flex-auto',
            style: {
              '-webkit-flex': 'auto',
              flex: 'auto',
              height: '20px',
              border: '0',
              'background-color': 'blue',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                height: '20px',
                border: '0',
                'background-color': 'blue',
                'box-sizing': 'border-box',
                width: '100px',
              },
            }),
          ]
        )),
        (flexAuto_1 = createElement('div', {
          'data-expected-width': '100',
          class: 'flex-auto',
          style: {
            '-webkit-flex': 'auto',
            flex: 'auto',
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        })),
        (flexAuto_2 = createElement(
          'div',
          {
            'data-expected-width': '300',
            class: 'flex-auto',
            style: {
              '-webkit-flex': 'auto',
              flex: 'auto',
              height: '20px',
              border: '0',
              'background-color': 'red',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                height: '20px',
                border: '0',
                'background-color': 'blue',
                'box-sizing': 'border-box',
                width: '200px',
              },
            }),
          ]
        )),
      ]
    );
    flexbox_24 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          width: '600px',
          'box-sizing': 'border-box',
          height: '60px',
          'flex-flow': 'row wrap',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            position: 'absolute',
          },
        }),
        createElement('div', {
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            height: '20px',
            border: '0',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '700px',
          },
        }),
      ]
    );
    div = createElement(
      'div',
      {
        'data-expected-width': '830',
        style: {
          'box-sizing': 'border-box',
          border: '1px 10px solid',
          display: 'inline-block',
        },
      },
      [
        (flexbox_25 = createElement(
          'div',
          {
            'data-expected-width': '700',
            class: 'flexbox',
            style: {
              display: 'flex',
              width: '600px',
              'box-sizing': 'border-box',
              'padding-left': '10px',
              'padding-right': '20px',
              'border-left': '1px 30px solid',
              'border-right': '1px 40px solid',
              'margin-left': '50px',
              'margin-right': '60px',
            },
          },
          [
            (flex1_20 = createElement('div', {
              'data-offset-x': '100',
              'data-expected-width': '200',
              class: 'flex1',
              style: {
                height: '20px',
                border: '0',
                'background-color': 'blue',
                flex: '1',
                'box-sizing': 'border-box',
              },
            })),
            (flex1_21 = createElement('div', {
              'data-offset-x': '300',
              'data-expected-width': '200',
              class: 'flex1',
              style: {
                height: '20px',
                border: '0',
                'background-color': 'green',
                flex: '1',
                'box-sizing': 'border-box',
              },
            })),
            (flex1_22 = createElement('div', {
              'data-offset-x': '500',
              'data-expected-width': '200',
              class: 'flex1',
              style: {
                height: '20px',
                border: '0',
                'background-color': 'red',
                flex: '1',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
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
    BODY.appendChild(flexbox_22);
    BODY.appendChild(flexbox_23);
    BODY.appendChild(flexbox_24);
    BODY.appendChild(flexbox_25);
    BODY.appendChild(div);

    await matchViewportSnapshot();
  });
});
