/*auto generated*/
describe('z-index', () => {
  it('blend-will-change-overlapping-layers', async () => {
    let div;
    let div_1;
    div = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        'z-index': '1',
        position: 'relative',
        height: '50vh',
      },
      [
        createElementWithStyle('div', {
          'box-sizing': 'border-box',
          'will-change': 'transform',
          position: 'absolute',
          bottom: '-100px',
          width: '100px',
          height: '100px',
          'background-color': 'red',
        }),
      ]
    );
    div_1 = createElementWithStyle('div', {
      'box-sizing': 'border-box',
      'z-index': '1',
      position: 'relative',
      'background-color': 'green',
      height: '100px',
    });
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        // window.scrollBy(0, 100);
        // takeScreenshot();
      });
    });

    await matchScreenshot();
  });

  it('with flex-item', async () => {
    let root;
    root = createElement(
      'div',
      {
        style: {
          display: 'flex',
          background: '#999',
          width: '200px',
          height: '200px',
          padding: '50px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'background-color': 'blue',
              height: '100px',
              'padding-left': '5px',
              width: '100px',
              zIndex: 3,
            },
          },
        ),
        createElement(
          'div',
          {
            style: {
              'position': 'absolute',
              top: '80px',
              'background-color': 'yellow',
              height: '100px',
              'padding-left': '5px',
              width: '100px',
              zIndex: 1,

            },
          },
        )
      ]
    );
    BODY.appendChild(root);

    await matchScreenshot();
  });

  it('without flex-item', async () => {
    let root;
    root = createElement(
      'div',
      {
        style: {
          background: '#999',
          width: '200px',
          height: '200px',
          padding: '50px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'background-color': 'blue',
              height: '100px',
              'padding-left': '5px',
              width: '100px',
              zIndex: 3,
            },
          },
        ),
        createElement(
          'div',
          {
            style: {
              'position': 'absolute',
              top: '80px',
              'background-color': 'yellow',
              height: '100px',
              'padding-left': '5px',
              width: '100px',
              zIndex: 1,

            },
          },
        )
      ]
    );

    BODY.appendChild(root);

    await matchScreenshot();
  });
});
