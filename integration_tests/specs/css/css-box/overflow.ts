describe('Overflow', () => {
  it('basic', async () => {
    var container = document.createElement('div');
    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      overflowX: 'scroll',
      overflowY: 'visible',
      width: '100px',
      height: '100px',
    });

    var inner1 = document.createElement('div');
    Object.assign(inner1.style, {
      width: '120px',
      height: '120px',
      backgroundColor: 'red',
    });
    div1.appendChild(inner1);
    container.appendChild(div1);

    var div2 = document.createElement('div');
    Object.assign(div2.style, {
      overflowX: 'visible',
      overflowY: 'hidden',
      width: '100px',
      marginTop: '40px',
      height: '100px',
    });
    var inner2 = document.createElement('div');
    Object.assign(inner2.style, {
      width: '120px',
      height: '120px',
      backgroundColor: 'red',
    });
    div2.appendChild(inner2);
    container.appendChild(div2);

    var div3 = document.createElement('div');
    Object.assign(div3.style, {
      overflowX: 'hidden',
      overflowY: 'scroll',
      width: '100px',
      marginTop: '40px',
      height: '100px',
    });
    var inner3 = document.createElement('div');
    Object.assign(inner3.style, {
      width: '120px',
      height: '120px',
      backgroundColor: 'red',
    });
    div3.appendChild(inner3);
    container.appendChild(div3);

    document.body.appendChild(container);

    await snapshot();
  });

  it('scrollTo', async (done) => {
    let container = document.createElement('div');
    let div1 = document.createElement('div');
    Object.assign(div1.style, {
      overflowX: 'scroll',
      overflowY: 'visible',
      width: '100px',
      height: '100px',
    });

    let inner1 = document.createElement('div');
    Object.assign(inner1.style, {
      width: '120px',
      height: '120px',
      background: 'conic-gradient(from -90deg, blue 0 25%, black 25% 50%, red 50% 75%, green 75% 100%)',
    });

    div1.appendChild(inner1);
    container.appendChild(div1);

    requestAnimationFrame(async () => {
      div1.scroll(20, 20);
      await snapshot();
      done();
    });
    document.body.appendChild(container);
  });

  it('overflow with inner padding', async (done) => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          height: '150px',
          border: '10px solid #f40',
          padding: '10px',
          overflow: 'auto',
          background: 'conic-gradient(from -90deg, blue 0 25%, black 25% 50%, red 50% 75%, green 75% 100%)',
        },
      }, [
        createText('London. Michaelmas term lately over, and the Lord Chancellor sitting in Lincolns Inn Hall. Implacable November weather. As much mud in the streets as if the waters had but newly retired from the face of the earth, and it would not be wonderful to meet a Megalosaurus, forty feet long or so, waddling like an elephantine lizard up Holborn Hill.')
      ],
    );
    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
      div.scroll(0, 20);
      await snapshot();
      done();
    });
  });

  it('overflow with flex container', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '150px',
          height: '150px',
          border: '10px solid #f40',
          padding: '10px',
          overflow: 'auto',
          background: 'conic-gradient(from -90deg, blue 0 25%, black 25% 50%, red 50% 75%, green 75% 100%)',
        },
      }, [
        createText('London. Michaelmas term lately over, and the Lord Chancellor sitting in Lincolns Inn Hall. Implacable November weather. As much mud in the streets as if the waters had but newly retired from the face of the earth, and it would not be wonderful to meet a Megalosaurus, forty feet long or so, waddling like an elephantine lizard up Holborn Hill.')
      ],
    );
    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
      div.scroll(0, 20);
      await snapshot();
    });
  });

  it('scrollLeft and scrollTop', async (done) => {
    let container = document.createElement('div');
    let div1 = document.createElement('div');
    Object.assign(div1.style, {
      overflowX: 'scroll',
      overflowY: 'visible',
      width: '100px',
      height: '100px',
    });

    let inner1 = document.createElement('div');
    Object.assign(inner1.style, {
      width: '120px',
      height: '120px',
      background: 'conic-gradient(from -90deg, blue 0 25%, black 25% 50%, red 50% 75%, green 75% 100%)',
    });

    div1.appendChild(inner1);
    container.appendChild(div1);
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      div1.scrollLeft = 20;
      div1.scrollTop = 20;

      await snapshot(0.1);
      done();
    });
  });

  it('borderRadius with overflow', async () => {
    let container = document.createElement('div');
    let child = document.createElement('div');
    child.style.width = '100px';
    child.style.height = '100px';
    child.style.background = 'red';
    container.appendChild(child);
    container.style.borderTopLeftRadius = '15px';
    container.style.borderTopRightRadius = '35px';
    container.style.borderBottomLeftRadius = '25px';
    container.style.borderBottomRightRadius = '50px';
    container.style.width = '100px';
    container.style.height = '100px';
    container.style.overflow = 'hidden';
    document.body.appendChild(container);

    await snapshot();
  });

  it('overflow with absolute positioned elements', async (done) => {
    let scroller;
    let container = createElement('div', {
      style: {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
      }
    }, [
      scroller = createElement('div', {
        style: {
          position: 'relative',
          width: '100px',
          height: '200px',
          'overflow-x': 'auto',
          'overflow-y': 'auto',
          border: '5px solid #000',
          padding: '5px'
        }
      }, [
        createElement('div', {
          style: {
            position: 'absolute',
            right: '-20px',
            color: 'red',
            display: 'inline',
            bottom: '-550px'
          }
        }, [
          createText('XXX')
        ])
      ])
    ]);

    document.body.appendChild(container);
    await snapshot();

    requestAnimationFrame(async () => {
      scroller.scroll(20, 550);
      await snapshot(0.2);
      done();
    });
  });

  it('scrollable area computed by max height children', async (done) => {
    let container;

    let array = new Array(100).fill(0);

    container = createViewElement(
      {
        overflow: 'scroll',
      },
      [
        createViewElement(
          {
            height: '20px',
            background: 'green'
          },
          []
        ),
        createViewElement(
          {
            height: '300px',
            background: 'pink'
          },
          [
            createViewElement(
              {},
              array.map((_, index) => {
                return createElement('div', {}, [createText(`${index}`)]);
              })
            ),
          ]
        ),
      ]
    );

    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.scrollTop = 30;
      await snapshot();
      requestAnimationFrame(async () => {
        container.scrollTop = 10000;
        await snapshot();

        done();
      });
    });
  });

  it('flex container\'s maxScrollableSize should care about flex-direction', async (doneFn) => {
    let container = createViewElement({
      overflow: 'scroll',
    }, [
      createElement('div', {
        style: {
          background: 'green',
          height: '100px'
        }
      }, [createText('1234')]),
      createElement('div', {
        style: {
          background: 'blue',
          height: '200px'
        }
      }, [createText('4567')]),
      createElement('div', {
        style: {
          background: 'red',
          height: '800px'
        }
      })
    ]);

    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      document.documentElement.scrollTop = 300;
      await snapshot();
      doneFn();
    });
  });

  it('hitTest with scroll offset', async () => {
    let box;
    let clickCount = 0;
    let container = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        overflow: 'scroll'
      }
    }, [
      createElement('div', {
        style: {
          width: '50px',
          height: '50px'
        }
      }, []),
      box = createElement('div', {
        style: {
          width: '50px',
          height: '50px'
        }
      }, []),
      createElement('div', {
        style: {
          width: '50px',
          height: '50px'
        }
      }, []),
      createElement('div', {
        style: {
          width: '50px',
          height: '50px'
        }
      }, []),
    ]);

    BODY.appendChild(container);

    box.addEventListener('click', () => clickCount++);

    await simulateClick(20, 60);

    await simulateSwipe(20, 60, 20, 0, 0.5);

    await simulateClick(20, 0);

    expect(clickCount).toBe(2);
  });

  // @TODO simulateSwipe method fails to trigger element scroll.
  // https://github.com/openkraken/kraken/issues/680
  xit('scroll works with overflowY set to auto and overflowX not set', async (done) => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          overflowY: 'auto',
        },
      }, [
        createElement(
          'div',
          {
            style: {
            width: '200px',
            height: '200px',
            backgroundColor: 'green',

            },
        }),
        createElement(
          'div',
          {
            style: {
            width: '200px',
            height: '200px',
            backgroundColor: 'yellow',

            },
        }),
      ],
    );
    BODY.appendChild(div);
    await snapshot();
    await simulateSwipe(50, 100, 50, 20, 0.1);

    setTimeout(async () => {
      await snapshot();
      done();
    }, 200);
  });
});