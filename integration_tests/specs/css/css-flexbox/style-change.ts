/*auto generated*/
describe('style', () => {
  it('change', async () => {
    let log;
    let p;
    let a;
    let b;
    let flexbox;
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
          `This test verifies that changing order, align-content, align-items, align-self, or justify-content will relayout.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        class: 'flexbox',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'box-sizing': 'border-box',
          width: '300px',
          height: '300px',
        },
      },
      [
        (a = createElement('div', {
          id: 'a',
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            'background-color': 'blue',
            'box-sizing': 'border-box',
            flex: '0 0 auto',
            width: '100px',
            height: '100px',
          },
        })),
        (b = createElement('div', {
          id: 'b',
          'data-offset-x': '100',
          'data-offset-y': '0',
          style: {
            'background-color': 'green',
            'box-sizing': 'border-box',
            flex: '0 0 auto',
            width: '100px',
            height: '100px',
          },
        })),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    (() => {
      var flexbox = document.getElementById('flexbox');
      var aDiv = document.getElementById('a');
      var bDiv = document.getElementById('b');

      flexbox.style.justifyContent = 'flex-end';

      flexbox.style.alignItems = 'flex-end';

      bDiv.style.order = -1;

      aDiv.style.alignSelf = 'flex-start';

      flexbox.style.width = '100px';
      flexbox.style.flexWrap = 'wrap';
      flexbox.style.alignContent = 'flex-end';
    })();

    await matchViewportSnapshot();
  });
});
