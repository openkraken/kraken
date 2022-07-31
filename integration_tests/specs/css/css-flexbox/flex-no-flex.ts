/*auto generated*/
describe('flex-no', () => {
  it('flex', async () => {
    let log;
    let flexbox;
    let flexbox_1;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    flexbox = createElement(
      'div',
      {
        class: 'flexbox row',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          width: '200px',
          height: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '50',
          style: {
            'background-color': 'blue',
            flex: 'none',
            width: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '150',
          style: {
            'background-color': 'green',
            flex: '1 auto',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-direction': 'column',
          width: '200px',
          height: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '50',
          style: {
            'background-color': 'blue',
            flex: 'none',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-height': '150',
          style: {
            'background-color': 'green',
            flex: '1 auto',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);

    function runTest() {
      document.body.className = 'noflex';
      checkLayout('.flexbox');
    }

    await matchViewportSnapshot();
  });
});
