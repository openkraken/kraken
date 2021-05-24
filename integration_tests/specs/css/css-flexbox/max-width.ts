/*auto generated*/
describe('max-width', () => {
  xit('violation', async () => {
    let log;
    let p;
    let p_1;
    let red;
    let column1;
    let column1_1;
    let column2;
    let column2_1;
    let columns;
    let columns_1;
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
      [createText(`You should see no red`)]
    );
    columns = createElement(
      'div',
      {
        class: 'columns',
        style: {
          display: 'flex',
          width: '800px',
          'box-sizing': 'border-box',
        },
      },
      [
        (red = createElement('div', {
          class: 'red',
          style: {
            background: 'red',
            position: 'absolute',
            width: '510px',
            height: '10px',
            'z-index': '-1',
            'box-sizing': 'border-box',
          },
        })),
        (column1 = createElement(
          'div',
          {
            class: 'column1',
            'data-expected-width': '150',
            style: {
              background: '#aaa',
              width: '800px',
              overflow: 'auto',
              'max-width': '150px',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
    Column 1
  `),
          ]
        )),
        (column2 = createElement(
          'div',
          {
            class: 'column2',
            'data-expected-width': '520',
            style: {
              background: '#aaa',
              flex: '0.8 0 0',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
    Column 2
  `),
          ]
        )),
      ]
    );
    p_1 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`This second part is just to ensure we don't assert`)]
    );
    columns_1 = createElement(
      'div',
      {
        class: 'columns',
        style: {
          display: 'flex',
          width: '800px',
          'box-sizing': 'border-box',
        },
      },
      [
        (column1_1 = createElement(
          'div',
          {
            class: 'column1 abspos',
            'data-expected-width': '150',
            style: {
              background: '#aaa',
              width: '800px',
              overflow: 'auto',
              'max-width': '150px',
              position: 'absolute',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
    Column 1
  `),
          ]
        )),
        (column2_1 = createElement(
          'div',
          {
            class: 'column2',
            'data-expected-width': '640',
            style: {
              background: '#aaa',
              flex: '0.8 0 0',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
    Column 2
  `),
          ]
        )),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(p);
    BODY.appendChild(columns);
    BODY.appendChild(p_1);
    BODY.appendChild(columns_1);

    await snapshot();
  });

  it('should work with flex-shrink 0', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          maxWidth: '50px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              flex: 'none',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`Hello world Hello world Hello world Hello world Hello world Hello world Hello world Hello world`)]
            ),
          ]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'width': '100px',
          backgroundColor: 'yellow',
        },
      },
    );
    div_1.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });

  it('should work with flex-shrink 1 and parent has width set', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          width: '90px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`Hello world Hello world Hello world Hello world Hello world Hello world Hello world Hello world`)]
            ),
          ]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'width': '100px',
          backgroundColor: 'yellow',
        },
      },
    );
    div_1.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });

  it('should work with flex-shrink 1 and parent has max-width set', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          width: '90px',
          maxWidth: '50px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`Hello world Hello world Hello world Hello world Hello world Hello world Hello world Hello world`)]
            ),
          ]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'width': '100px',
          backgroundColor: 'yellow',
        },
      },
    );
    div_1.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
});
