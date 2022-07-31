/*auto generated*/
describe('overflow-keep', () => {
  it('scrollpos', async () => {
    let log;
    let flex;
    let sidebar;
    let container;
    let console;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        class: 'container flexbox',
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flex = createElement(
          'div',
          {
            class: 'flex overflow-auto flexbox',
            style: {
              display: 'flex',
              overflow: 'auto',
              flex: '1',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                height: '400px',
              },
            }),
          ]
        )),
        (sidebar = createElement(
          'div',
          {
            id: 'sidebar',
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`foo`)]
        )),
      ]
    );
    console = createElement('div', {
      id: 'console',
      style: {
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(log);
    BODY.appendChild(container);
    BODY.appendChild(console);

    await matchViewportSnapshot();
  });
});
