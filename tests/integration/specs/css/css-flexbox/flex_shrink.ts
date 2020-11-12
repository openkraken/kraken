describe('flexbox flex-shrink', () => {
  it('should work when flex-direction is row', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      display: 'flex',
      flexDirection: 'row',
      width: '500px',
      height: '100px',
      marginBottom: '10px',
    });

    document.body.appendChild(container1);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      backgroundColor: '#999',
      width: '300px',
    });
    child1.appendChild(document.createTextNode('flex-shrink: 1'));
    container1.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      flexShrink: 2,
      backgroundColor: '#f40',
      width: '200px',
    });
    child2.appendChild(document.createTextNode('flex-shrink: 2'));
    container1.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      flexShrink: 1,
      backgroundColor: 'green',
      width: '200px',
    });
    child3.appendChild(document.createTextNode('flex-shrink: 1'));
    container1.appendChild(child3);

    await matchViewportSnapshot();
  });

  it('should work when flex-direction is column', async () => {
    const container2 = document.createElement('div');
    setElementStyle(container2, {
      display: 'flex',
      flexDirection: 'column',
      width: '500px',
      height: '400px',
      marginBottom: '10px',
    });

    document.body.appendChild(container2);

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      backgroundColor: '#999',
      height: '300px',
    });
    child4.appendChild(document.createTextNode('flex-shrink: 1'));
    container2.appendChild(child4);

    const child5 = document.createElement('div');
    setElementStyle(child5, {
      flexShrink: 2,
      backgroundColor: '#f40',
      height: '200px',
    });
    child5.appendChild(document.createTextNode('flex-shrink: 2'));
    container2.appendChild(child5);

    const child6 = document.createElement('div');
    setElementStyle(child6, {
      flexShrink: 1,
      backgroundColor: 'green',
      height: '200px',
    });
    child6.appendChild(document.createTextNode('flex-shrink: 1'));
    container2.appendChild(child6);

    await matchViewportSnapshot();
  });
  it('not shrink no defined size elements', async () => {
    let element = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'display': 'flex',
        'position': 'relative',
        'flex-direction': 'column',
        'flex-shrink': 0,
        'align-content': 'flex-start',
        'margin': '0vw',
        padding: '0vw',
        'min-width': '0vw',
        height: '640px'
      }
    }, [
      createElement('div', {
        style: {
          'box-sizing': 'border-box',
          'display': 'flex',
          'position': 'relative',
          'flex-direction': 'column',
          'flex-shrink': 0,
          'align-content': 'flex-start',
          'margin': '0vw',
          padding: '0vw',
          'min-width': '0vw',
          height: '20px',
          'aligm-items': 'center',
          background: 'blue'
        }
      })
    ]);
    BODY.appendChild(element);
    await matchViewportSnapshot();
  });

  it('scrollable height auto computed by flex container', async (done) => {
    let container;
    let list = new Array(100).fill(0);
    let scroller;
    container = createViewElement(
      {
        width: '200px',
        height: '500px',
        flexShrink: 1,
        border: '2px solid #000',
      },
      [
        createViewElement(
          {
            height: '20px',
          },
          []
        ),
        scroller = createViewElement(
          {
            flex: 1,
            width: '200px',
            overflow: 'scroll',
          },
          list.map((_, index) => {
            return createElement('div', {}, [createText(`${index}`)]);
          })
        ),
      ]
    );

    BODY.appendChild(container);

    await matchViewportSnapshot();

    requestAnimationFrame(async () => {
      scroller.scrollTop = 400;
      await matchViewportSnapshot();
      done();
    });
  });

  it('should work with intrinsic element with no min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
        }),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with intrinsic element with min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            minHeight: '30px'
          }
        }),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with intrinsic element with width and no height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
              width: '30px'
          }
        }),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flex layout in the column direction with children and height is not larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              flexDirection: 'column',
              height: '100px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flex layout in the column direction with children and height is larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              flexDirection: 'column',
              height: '300px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flex layout in the column direction with children and min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              flexDirection: 'column',
              height: '300px',
              minHeight: '30px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flex layout in the row direction with children and height is not larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              height: '50px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flex layout in the row direction with children and height is larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              height: '250px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flex layout in the row direction with children and min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              height: '250px',
              minHeight: '30px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flow layout with children and height is not larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '100px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '200px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flow layout with children and height is larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '300px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '200px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });

  it('should work with flow layout with children and min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
         (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '300px',
              minHeight: '30px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await matchViewportSnapshot();
  });
});
