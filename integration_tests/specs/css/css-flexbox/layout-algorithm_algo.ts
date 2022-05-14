/*auto generated*/
describe('layout-algorithm_algo', () => {
  it('cross-line-001', async () => {
    let p;
    let flex;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square with scrollbars and `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    flex = createElement(
      'div',
      {
        class: 'flex',
        style: {
          width: '200px',
          display: 'flex',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'green',
            height: '200px',
            flex: '1',
            overflow: 'scroll',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'green',
            height: '200px',
            flex: '1',
            overflow: 'scroll',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flex);

    await snapshot();
  });
  it('cross-line-002', async () => {
    let p;
    let flex;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square with scrollbars and `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    flex = createElement(
      'div',
      {
        class: 'flex',
        style: {
          width: '200px',
          height: '200px',
          display: 'flex',
          background: 'red',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'green',
            width: '200px',
            height: '100px',
            overflow: 'scroll',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'green',
            width: '200px',
            height: '100px',
            overflow: 'scroll',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flex);

    await snapshot();
  });
});
