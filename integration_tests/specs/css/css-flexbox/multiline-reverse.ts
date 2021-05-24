/*auto generated*/
describe('multiline-reverse', () => {
  it('wrap-baseline with margin-top', async () => {
    let flexbox;
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
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('wrap-baseline with margin-bottom', async () => {
    let flexbox_1;
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
    BODY.appendChild(flexbox_1);

    await snapshot();
  });

  xit('wrap-baseline with more than 2 flex-item', async () => {
    let flexbox_2;
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
    // BODY.appendChild(flexbox_2);

    await snapshot();
  });

  it('should work with align-items flex-start', async () => {
    let flexbox;
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
          'align-items': 'flex-start',
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
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('should work with align-items flex-end', async () => {
    let flexbox;
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
          'align-items': 'flex-end',
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
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('should work with align-items center', async () => {
    let flexbox;
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
          'align-items': 'center',
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
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('should work with align-items baseline', async () => {
    let flexbox;
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
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('should work with align-items stretch', async () => {
    let flexbox;
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
          'align-items': 'stretch',
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
    BODY.appendChild(flexbox);

    await snapshot();
  });
});
