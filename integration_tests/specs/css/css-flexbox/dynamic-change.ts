/*auto generated*/
describe('dynamic-change', () => {
  xit('simplified-layout-002', async () => {
    let target;
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          width: '100px',
          height: '100px',
          'background-color': 'red',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              contain: 'layout size',
              height: '100px',
              flex: '1',
              'background-color': 'green',
            },
          },
          [
            (target = createElement('div', {
              id: 'target',
              style: {
                'box-sizing': 'border-box',
              },
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    // document.body.offsetTop;
    // document.getElementById('target').style.width = '1px';

    await snapshot();

    await snapshot();
  });
  it('simplified-layout', async () => {
    let child;
    let it1;
    let it2;
    let flex;
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          position: 'relative',
        },
      },
      [
        (flex = createElement(
          'div',
          {
            id: 'flex',
            style: {
              display: 'flex',
              'flex-direction': 'column',
              'flex-wrap': 'wrap',
              position: 'absolute',
              top: '20px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            (it1 = createElement(
              'div',
              {
                id: 'it1',
                style: {
                  'background-color': 'green',
                  flex: 'none',
                  height: '100px',
                  'min-height': '0',
                  position: 'relative',
                  'box-sizing': 'border-box',
                },
              },
              [
                (child = createElement('div', {
                  id: 'child',
                  style: {
                    position: 'absolute',
                    top: '0',
                    left: '0',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            )),
            (it2 = createElement('div', {
              id: 'it2',
              style: {
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(div);
    await snapshot();

    it2.style.width = '50px';
    flex.style.top = '0px';
    child.style.top = '1px';

    await snapshot();
  });

  it('flex item height change', async (done) => {
    let div;
    let item1;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            background: 'red',
          }
        })),
        createElement('div', {
          style: {
            flex: 1,
            background: 'blue',
          }
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      item1.style.height = '100px';
      await snapshot();
      done();
    });
  });

  it('flex grow exists when its sibling main size changes when flex direction is row', async (done) => {
    let div;
    let item1;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            background: 'red',
          }
        })),
        createElement('div', {
          style: {
            flex: 1,
            background: 'blue',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
      item1.style.width = '200px';
      await snapshot();
      done();
    });
  });

  it('flex shrink exists when its sibling main size changes when flex direction is row', async (done) => {
    let div;
    let item1;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            background: 'red',
          }
        })),
        createElement('div', {
          style: {
            width: '500px',
            background: 'blue',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
      item1.style.width = '200px';
      await snapshot();
      done();
    });
  });

  it('flex shorthand exists when its sibling main size changes when flex direction is row', async (done) => {
    let div;
    let item1;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            background: 'red',
          }
        })),
        createElement('div', {
          style: {
            flex: 1,
            width: '500px',
            background: 'blue',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
      item1.style.width = '200px';
      await snapshot();
      done();
    });
  });

  it('flex grow exists when its sibling main size changes when flex direction is column', async (done) => {
    let div;
    let item1;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '300px',
          height: '200px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            background: 'red',
          }
        })),
        createElement('div', {
          style: {
            flex: 1,
            background: 'blue',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
      item1.style.height = '100px';
      await snapshot();
      done();
    });
  });

  it('flex shrink exists when its sibling main size changes when flex direction is column', async (done) => {
    let div;
    let item1;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '200px',
          flexDirection: 'column',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            background: 'red',
          }
        })),
        createElement('div', {
          style: {
            height: '500px',
            background: 'blue',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
      item1.style.height = '100px';
      await snapshot();
      done();
    });
  });

  it('change inner box width in nested flex layout', async (done) => {
    let div;
    let div2;
    let div3;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-flex',
          flexDirection: 'column',
          padding: '10px',
          backgroundColor: 'green',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            display: 'inline-flex',
            flexDirection: 'column',
            backgroundColor: 'yellow',
            padding: '10px',
          }
        }, [
          (div3 = createElement('div', {
            style: {
              display: 'inline-flex',
              flexDirection: 'column',
              backgroundColor: 'lightblue',
              width: '200px',
            }
          }, [
            createText('The quick brown fox jumps over the lazy dog.')
          ]))
        ]))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div3.style.width = '300px';
      await snapshot();
      done();
    });
  });

  it('change outer box width in nested flex layout', async (done) => {
    let div;
    let div2;
    let div3;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-flex',
          flexDirection: 'column',
          width: '200px',
          padding: '10px',
          backgroundColor: 'green',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            display: 'inline-flex',
            flexDirection: 'column',
            backgroundColor: 'yellow',
            padding: '10px',
          }
        }, [
          (div3 = createElement('div', {
            style: {
              display: 'inline-flex',
              flexDirection: 'column',
              backgroundColor: 'lightblue',
            }
          }, [
            createText('The quick brown fox jumps over the lazy dog.')
          ]))
        ]))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div.style.width = '300px';
      await snapshot();
      done();
    });
  });

  it('height of flex item with flex-grow should expand when its content changes', async (done) => {
    let div;
    let child;
    let item;
    div = createElement(
    'div',
      {
        style: {
          display: 'flex',
          backgroundColor: 'grey',
          padding: '10px'
        },
      },
      [
        (createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            backgroundColor: 'yellow',
          }
        })),
        (child = createElement('div', {
          style: {
            flexGrow: 1,
            display: 'flex',
            backgroundColor: 'green',
            padding: '10px'
          }
        }, [
          (item = createElement('div', {
            style: {
              flex: 1,
              backgroundColor: 'coral',
            }
          }))
        ])
        )
      ]
    );

    document.body.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      item.style.height = '200px';
      await snapshot();
      done();
    });
  });

 it('width of flex item with flex-grow should expand when its content changes', async (done) => {
    let div;
    let child;
    let item;
    div = createElement(
    'div',
      {
        style: {
          display: 'inline-flex',
          flexDirection: 'column',
          backgroundColor: 'grey',
          padding: '10px'
        },
      },
      [
        (createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            backgroundColor: 'yellow',
          }
        })),
        (child = createElement('div', {
          style: {
            flexGrow: 1,
            backgroundColor: 'green',
            padding: '10px'
          }
        }, [
          (item = createElement('div', {
            style: {
              height: '100px',
              backgroundColor: 'coral',
            }
          }))
        ])
        )
      ]
    );

    document.body.appendChild(div);

    await snapshot();
    
    requestAnimationFrame(async () => {
      item.style.width = '300px';
      await snapshot();
      done();
    });
  });
});
