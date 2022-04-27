/*auto generated*/
describe('flexbox-width', () => {
  it('with-overflow-auto', async () => {
    let log;
    let overflow;
    let target;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    target = createElement(
      'div',
      {
        id: 'target',
        class: 'flexbox',
        'data-expected-width': '47',
        style: {
          display: 'inline-flex',
          border: '5px solid green',
          position: 'relative',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (overflow = createElement(
          'div',
          {
            class: 'overflow',
            style: {
              border: '1px solid red',
              overflow: 'auto',
              'min-width': '0',
              'min-height': '0',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                height: '100px',
                width: '20px',
              },
            }),
          ]
        )),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(target);

    await matchViewportSnapshot();
  });
});
