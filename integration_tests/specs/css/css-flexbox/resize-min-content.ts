/*auto generated*/
describe('resize-min', () => {
  it('content-flexbox', async () => {
    let log;
    let content;
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
        class: 'flexbox column justify-content-center align-items-center',
        'data-expected-height': '100',
        style: {
          'min-height': 'min-content',
          background: 'green',
          height: '100%',
          'box-sizing': 'border-box',
        },
      },
      [
        (content = createElement('div', {
          id: 'content',
          'data-expected-height': '100',
          style: {
            height: '1000px',
            'max-height': '100%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.style.height = '100%';
    document.documentElement.style.height = '100%';

    document.body.offsetHeight;
    document.documentElement.style.height = '100px';

    checkLayout('.flexbox');

    await matchViewportSnapshot();
  });
});
