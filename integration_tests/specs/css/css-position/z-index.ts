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

    await matchViewportSnapshot();
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

    await matchViewportSnapshot();
  });

  it('two flex items with both zIndex', async () => {
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
          position: 'relative',
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

    await matchViewportSnapshot();
  });

  it('two flex items of zIndex and no zIndex', async () => {
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
          position: 'relative',
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
            },
          },
        )
      ]
    );
    BODY.appendChild(root);

    await matchViewportSnapshot();
  });

  it('two flex items of both no zIndex', async () => {
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
          position: 'relative',
        },
      },
      [
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
            },
          },
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'blue',
              height: '100px',
              'padding-left': '5px',
              width: '100px',
            },
          },
        ),
      ]
    );
    BODY.appendChild(root);

    await matchViewportSnapshot();
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

    await matchViewportSnapshot();
  });

  it('with z-index change', async (done) => {
    let root;
    let div1;
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
        (div1 = createElement(
          'div',
          {
            style: {
              position: 'relative',
              top: 0,
              left: 0,
              'background-color': 'blue',
              height: '90px',
              'padding-left': '5px',
              width: '90px',
              zIndex: 200,
              transform: 'translate(0, 0)'
            },
          },
        )),
        createElement(
          'div',
          {
            style: {
              'position': 'relative',
              top: '-100px',
              left: 0,
              'background-color': 'yellow',
              height: '100px',
              width: '100px',
              zIndex: 100,
              transform: 'translate(0, 50px)'
            },
          },
        )
      ]
    );

    BODY.appendChild(root);

    await matchViewportSnapshot();

    requestAnimationFrame(async () => {
      div1.style.zIndex = 99;
      await matchViewportSnapshot(0.1);
      done();
    });
  });

  it('works with z-index compare 1', async () => {
    let root;
    let div1;
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
        (div1 = createElement(
          'div',
          {
            style: {
              position: 'absolute',
              top: 0,
              left: 0,
              'background-color': 'blue',
              height: '100px',
              'padding-left': '5px',
              width: '100px',
              zIndex: 5,
            },
          },
        )),
        createElement(
          'div',
          {
            style: {
              top: '50px',
              'position': 'absolute',
              left: 0,
              'background-color': 'yellow',
              height: '100px',
              width: '100px',
              zIndex: 10,
            },
          },
        )
      ]
    );

    BODY.appendChild(root);

    await matchViewportSnapshot();
  });

  it('works with z-index compare 2', async () => {
    let root;
    let div1;
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
        (div1 = createElement(
          'div',
          {
            style: {
              top: 0,
              left: 0,
              position: 'absolute',
              'background-color': 'blue',
              height: '100px',
              'padding-left': '5px',
              width: '100px',
              zIndex: 20,
            },
          },
        )),
        createElement(
          'div',
          {
            style: {
              top: '50px',
              'position': 'absolute',
              left: 0,
              'background-color': 'yellow',
              height: '100px',
              width: '100px',
              zIndex: 10,
            },
          },
        )
      ]
    );

    BODY.appendChild(root);

    await matchViewportSnapshot();
  });
});
