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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();

    requestAnimationFrame(async () => {
      div1.style.zIndex = 99;
      await snapshot(0.1);
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

    await snapshot();
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

    await snapshot();
  });

  it('works with click', async (done) => {
    const div = document.createElement('div');
    div.style.position = 'relative';
    div.style.width = '100px';
    div.style.height = '100px';

    const div2 = document.createElement('div');
    div2.style.position = 'absolute';
    div2.style.zIndex = '2';
    div2.style.width = '100%';
    div2.style.height = '100%';
    div2.style.background = 'blue';
    div2.addEventListener('click', ()=>{
      done();
    })

    const div3 = document.createElement('div');
    div3.style.position = 'absolute';
    div3.style.zIndex = '1';
    div3.style.width = '100%';
    div3.style.height = '100%';
    div3.style.background = 'red';

    document.body.appendChild(div);
    div.appendChild(div2);
    div.appendChild(div3);

    await simulateClick(10, 10);
  });

  it('works with zIndex order in flow layout', async (done) => {
    let div = createElement(
      'div', {
        style: {
          position: 'relative',
          width: '200px',
          height: '400px',
        },
      });

    let div1 = createElement(
      'div', {
        style: {
            position: 'relative',
            top: '50px',
            width: '200px',
            height: '100px',
            backgroundColor: 'green',
            zIndex: 1,
        },
      });

    let div2 = createElement(
      'div', {
        style: {
            width: '200px',
            height: '100px',
            backgroundColor: 'yellow',
        },
      });

    let div3 = createElement(
      'div', {
        style: {
            width: '200px',
            height: '100px',
            backgroundColor: 'red',
            position: 'absolute',
            top: '120px',
        },
      });
    let div4 = createElement(
      'div', {
        style: {
            position: 'relative',
            width: '100px',
            height: '100px',
            backgroundColor: 'pink',
        },
      });
    
    BODY.appendChild(div);
    div.appendChild(div1);
    div.appendChild(div2);
  
    await snapshot();

    requestAnimationFrame(async () => {
        div.removeChild(div2);
        div.appendChild(div3);
        div.insertBefore(div4, div3);
        div4.style.zIndex = 10;
        await snapshot();
        done();
    });
  });

  it('works with zIndex order in flex layout', async (done) => {
    let div = createElement(
      'div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          position: 'relative',
          width: '200px',
          height: '400px',
        },
      });

    let div1 = createElement(
      'div', {
        style: {
            position: 'relative',
            top: '50px',
            width: '200px',
            height: '100px',
            backgroundColor: 'green',
            zIndex: 1,
        },
      });

    let div2 = createElement(
      'div', {
        style: {
            width: '200px',
            height: '100px',
            backgroundColor: 'yellow',
        },
      });

    let div3 = createElement(
      'div', {
        style: {
            width: '200px',
            height: '100px',
            backgroundColor: 'red',
            position: 'absolute',
            top: '120px',
        },
      });
    let div4 = createElement(
      'div', {
        style: {
            position: 'relative',
            width: '100px',
            height: '100px',
            backgroundColor: 'pink',
        },
      });
    
    BODY.appendChild(div);
    div.appendChild(div1);
    div.appendChild(div2);
  
    await snapshot();

    requestAnimationFrame(async () => {
        div.removeChild(div2);
        div.appendChild(div3);
        div.insertBefore(div4, div3);
        div4.style.zIndex = 10;
        await snapshot();
        done();
    });
  });

});
