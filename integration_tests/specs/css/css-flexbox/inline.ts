/*auto generated*/
describe('inline', () => {
  it('flex', async () => {
    let log;
    let p;
    let testcase;
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
          `This test passes if the three green boxes are on the same horizontal line.`
        ),
      ]
    );
    testcase = createElement(
      'div',
      {
        id: 'testcase',
        style: {
          'box-sizing': 'border-box',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          'data-offset-y': '0',
          'data-offset-x': '0',
          'data-expected-width': '50',
          'data-expected-height': '50',
          style: {
            height: '50px',
            width: '50px',
            'background-color': 'green',
            outline: '2px solid darkgreen',
            'box-sizing': 'border-box',
            display: 'inline-block',
          },
        }),
        createElement(
          'div',
          {
            'data-offset-y': '0',
            'data-offset-x': '50',
            'data-expected-width': '50',
            'data-expected-height': '50',
            style: {
              height: '50px',
              width: '50px',
              'background-color': 'green',
              outline: '2px solid darkgreen',
              'box-sizing': 'border-box',
              display: 'inline-flex',
            },
          },
          [
            createElement('div', {
              'data-expected-width': '25',
              style: {
                flex: '1',
                'box-sizing': 'border-box',
              },
            }),
            createElement('div', {
              'data-expected-width': '25',
              style: {
                flex: '1',
                'box-sizing': 'border-box',
              },
            }),
          ]
        ),
        createElement('div', {
          'data-offset-y': '0',
          'data-offset-x': '100',
          'data-expected-width': '50',
          'data-expected-height': '50',
          style: {
            height: '50px',
            width: '50px',
            'background-color': 'green',
            outline: '2px solid darkgreen',
            'box-sizing': 'border-box',
            display: 'inline-block',
          },
        }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(p);
    BODY.appendChild(testcase);

    await snapshot();
  });
});
