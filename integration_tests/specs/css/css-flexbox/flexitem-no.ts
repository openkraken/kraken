/*auto generated*/
describe('flexitem-no', () => {
  it('margin-collapsing', async () => {
    let log;
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
          'background-color': 'lightgrey',
          'box-sizing': 'border-box',
          position: 'relative',
        },
      },
      [
        createElement(
          'div',
          {
            'data-offset-x': '0',
            'data-offset-y': '0',
            'data-expected-width': '120',
            'data-expected-height': '120',
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('p', {
              'data-offset-x': '10',
              'data-offset-y': '10',
              'data-expected-width': '100',
              'data-expected-height': '100',
              style: {
                height: '100px',
                width: '100px',
                margin: '10px',
                'background-color': 'blue',
                'box-sizing': 'border-box',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);

    await snapshot();
  });
});
