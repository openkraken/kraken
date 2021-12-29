describe('Position fixed', () => {
  it('001', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      width: '200px',
      height: '200px',
      backgroundColor: '#999',
      position: 'relative',
      top: '100px',
      left: '100px',
    });
    document.body.appendChild(container1);

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'fixed',
      top: '50px',
      left: '50px',
    });
    div1.appendChild(document.createTextNode('fixed element'));
    container1.appendChild(div1);
    await snapshot(container1);
  });

  it('works with scroller container', async () => {
    let container = createElement('div',
      {
        style: {
          width: '100px',
          height: '100px',
          overflow: 'scroll',
          backgroundColor: '#999',
        },
      },
      [
        createText('12345'),
        createElement('div', {
          style: {
            width: '50px',
            height: '550px',
            background: 'red',
            top: '50px',
          },
        }),
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            background: 'green',
            position: 'fixed',
            top: '50px',
          },
        }),
      ]
    );

    BODY.appendChild(container);
    await snapshot();

    container.scroll(0, 200);
    await snapshot();

  });

  it('works with window scroll', async () => {
    let container = createElement('div',
      {
        style: {
          width: '100px',
          backgroundColor: '#999',
        },
      },
      [
        createText('12345'),
        createElement('div', {
          style: {
            width: '50px',
            height: '900px',
            background: 'red',
            top: '50px',
          },
        }),
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            background: 'green',
            position: 'fixed',
            top: '50px',
          },
        }),
      ]
    );

    BODY.appendChild(container);
    await snapshot();

    window.scroll(0, 200);
    await snapshot();

  });
  // FIXME: Current scroll in horizontal axis is not work in viewport
  xit('works with single frame image in window scroll', async () => {
    let container = createElement('div',
      {
        style: {
          width: '600px',
          backgroundColor: '#999',
        },
      },
      [
        createText('12345'),
        createElement('div', {
          style: {
            width: '50px',
            height: '900px',
            background: 'red',
            top: '50px',
          },
        }),
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            width: '100px',
            height: '100px',
            background: 'green',
            position: 'fixed',
            top: '50px',
            left: '50px',
          },
        }),
      ]
    );

    BODY.appendChild(container);
    await snapshot(0.5);

    window.scroll(100, 200);
    await snapshot();
  });

  it('hitTest with position fixed elements', async () => {
    let box;
    let clickCount = 0;
    let container = createViewElement({
      width: '200px',
      height: '200px',
      border: '1px solid #000',
      overflow: 'scroll'
    }, [
      box = createElement('div', {
        style: {
          width: '50px',
          height: '50px',
          position: 'fixed',
          background: 'red',
          top: 0
        }
      }),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
    ]);

    BODY.appendChild(container);

    box.onclick = () => clickCount++;

    await simulateClick(10, 10);

    container.scrollTop = 20;

    await simulateClick(10, 10);


    expect(clickCount).toBe(2);

  });

  it('works with left, right and no width', async () => {
    let test01;
    test01 = createElement(
      'div',
      {
        style: {
          position: 'fixed',
          left: 0,
          right: 0,
          height: '50px',
          'background-color': 'green',
          display: 'flex',
          flexDirection: 'row'
        },
      },
      [
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            'flex-direction': 'column',
            flex: '1 1 0',
            'align-items': 'center',
            backgroundColor: 'red',
          }
        }, [
          createText('A')
        ]),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            'flex-direction': 'column',
            flex: '1 1 0',
            'align-items': 'center',
            backgroundColor: 'blue',
          }
        }, [
          createText('B')
        ])
      ]
    );

    BODY.appendChild(test01);

    await snapshot();
  });

  it('change from fixed to static and transform exists', async () => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          backgroundColor: 'green',
          position: 'fixed',
          top: '100px',
          transform: 'translate(100px, 0)',
        }
      },
      [
        createText(`1234`)
      ]
    );
    append(BODY, cont);
    await snapshot();

    cont.style.position = 'static';
    await snapshot();
  });

  it('change from fixed to static and no transform exists', async () => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          backgroundColor: 'green',
          position: 'fixed',
          top: '100px',
        }
      },
      [
        createText(`1234`)
      ]
    );
    append(BODY, cont);
    await snapshot();

    cont.style.position = 'static';
    await snapshot();
  });

  it('should work with parent zIndex of parent fixed element larger than zIndex of child fixed element', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          position: 'fixed',
          width: '200px',
          height: '200px',
          background: 'yellow',
          zIndex: 1000,
        },
      },
      [
        createElement('div', {
          style: {
            position: 'fixed',
            width: '100px',
            height: '100px',
            'background-color': 'green',
            zIndex: 100,
          },
        }),
      ]
    );

    document.body.appendChild(div);

    await snapshot();
  });

  it('should work with parent zIndex of parent fixed element larger than zIndex of child fixed element in nested container', async () => {
    let div;
    div = createElement('div', {
       style: {
       }
    }, [
      createElement(
        'div',
        {
            style: {
            position: 'fixed',
            width: '200px',
            height: '200px',
            background: 'yellow',
            zIndex: 1000,
            },
        },
        [
            createElement('div', {
            style: {
                position: 'fixed',
                width: '100px',
                height: '100px',
                display: 'flex',
                'background-color': 'green',
                zIndex: 100,
            },
            }),
        ]
      )
    ]);

    document.body.appendChild(div);

    await snapshot();
  });
});
