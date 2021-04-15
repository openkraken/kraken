/*auto generated*/
describe('available-height', () => {
  xit('for-replaced-content-001', async () => {
    let log;
    let wrapper;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    wrapper = createElement(
      'div',
      {
        id: 'wrapper',
        style: {
          width: '200px',
          'min-height': '1px',
          height: '20px',
          border: '1px solid green',
          padding: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          src: '',
          'data-expected-height': '20',
          style: {
            margin: '0',
            padding: '0',
            border: '0',
            width: '100%',
            height: '100%',
            background: 'silver',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(wrapper);

    await snapshot();
  });
});
