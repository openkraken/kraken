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

    await matchScreenshot();
  });
});
