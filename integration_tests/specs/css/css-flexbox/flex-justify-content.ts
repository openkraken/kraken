/*auto generated*/
describe('flex-justify', () => {
  it('content', async () => {
    let log;
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
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '100',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '200',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'flex-end',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '300',
          style: {
            height: '20px',
            border: '0',
            flex: '0 0 100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '400',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '500',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'center',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '150',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '250',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '350',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'center',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '200',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '400',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'red',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_4 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'center',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '800',
          'data-offset-x': '-100',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            width: '800px',
          },
        }),
      ]
    );
    flexbox_5 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-between',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '250',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '500',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
      ]
    );
    flexbox_6 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-between',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '200',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '400',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'red',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_7 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-between',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        }),
      ]
    );
    flexbox_8 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-around',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '50',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '250',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '450',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
      ]
    );
    flexbox_9 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-around',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '250',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        }),
      ]
    );
    flexbox_10 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-around',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '800',
          'data-offset-x': '-100',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            width: '800px',
          },
        }),
      ]
    );
    flexbox_11 = createElement('div', {
      class: 'flexbox',
      style: {
        width: '600px',
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'box-sizing': 'border-box',
        'justify-content': 'space-around',
      },
    });
    flexbox_12 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '75',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '250',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '425',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
      ]
    );
    flexbox_13 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '200',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '400',
          style: {
            height: '20px',
            border: '0',
            flex: '1 100px',
            'background-color': 'red',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_14 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '250',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 0',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            'max-width': '100px',
          },
        }),
      ]
    );
    flexbox_15 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '800',
          'data-offset-x': '-100',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            width: '800px',
          },
        }),
      ]
    );
    flexbox_16 = createElement('div', {
      class: 'flexbox',
      style: {
        width: '600px',
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'box-sizing': 'border-box',
        'justify-content': 'space-evenly',
      },
    });
    flexbox_17 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'flex-end',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'blue',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '100',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '100px',
            'margin-right': 'auto',
          },
        }),
        createElement('div', {
          'data-expected-width': '100',
          'data-offset-x': '500',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '100px',
          },
        }),
      ]
    );
    flexbox_18 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'flex-end',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '0',
          style: {
            height: '20px',
            border: '0',
            flex: '0 1 300px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '200',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '200px',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '400',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '200px',
          },
        }),
      ]
    );
    flexbox_19 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '600px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          'justify-content': 'flex-end',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '300',
          'data-offset-x': '-100',
          style: {
            height: '20px',
            border: '0',
            flex: '1 0 300px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '200',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'green',
            'box-sizing': 'border-box',
            width: '200px',
          },
        }),
        createElement('div', {
          'data-expected-width': '200',
          'data-offset-x': '400',
          style: {
            height: '20px',
            border: '0',
            flex: 'none',
            'background-color': 'red',
            'box-sizing': 'border-box',
            width: '200px',
          },
        }),
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

    await matchViewportSnapshot();
  });
});
