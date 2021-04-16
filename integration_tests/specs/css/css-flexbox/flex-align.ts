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
});
