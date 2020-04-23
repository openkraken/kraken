/*auto generated*/
describe('position-absolute', () => {
  xit('center-001.tentative', async () => {
    let innerFlex;
    let containingBlock;
    containingBlock = create(
      'div',
      {
        position: 'relative',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        display: 'flex',
        'flex-direction': 'row',
      },
      [
        (innerFlex = create(
          'div',
          {
            'flex-grow': '1',
            display: 'flex',
            'justify-content': 'center',
            margin: '10px',
            height: '100px',
          },
          [
            create(
              'div',
              {
                position: 'absolute',
                top: '0',
                height: '100px',
                'background-color': 'green',
              },
              [
                create('span', {
                  display: 'inline-block',
                  width: '50px',
                }),
                create('span', {
                  display: 'inline-block',
                  width: '50px',
                }),
              ]
            ),
          ]
        )),
        create('div', {
          'flex-grow': '1',
          height: '100px',
          'background-color': 'green',
        }),
      ]
    );
    BODY.appendChild(containingBlock);

    await matchScreenshot();
  });
  xit('center-002.tentative', async () => {
    let innerFlex;
    let containingBlock;
    containingBlock = create(
      'div',
      {
        position: 'relative',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        display: 'flex',
        'flex-direction': 'column',
      },
      [
        (innerFlex = create(
          'div',
          {
            'flex-grow': '1',
            display: 'flex',
            'align-items': 'center',
            margin: '10px',
            width: '100px',
          },
          [
            create(
              'div',
              {
                position: 'absolute',
                left: '0',
                width: '100px',
                'background-color': 'green',
              },
              [
                create('span', {
                  display: 'inline-block',
                  height: '50px',
                  width: '50px',
                }),
                create('span', {
                  display: 'inline-block',
                  height: '50px',
                  width: '50px',
                }),
              ]
            ),
          ]
        )),
        create('div', {
          'flex-grow': '1',
          width: '100px',
          'background-color': 'green',
        }),
      ]
    );
    BODY.appendChild(containingBlock);

    await matchScreenshot();
  });
  xit('chrome-bug-001', async () => {
    let target;
    let container;
    container = create(
      'div',
      {
        position: 'relative',
        border: '1px solid black',
        width: '200px',
        height: '300px',
      },
      [
        (target = create('span', {
          'background-color': 'green',
          position: 'absolute',
          width: '50px',
          height: '30px',
          left: '50%',
          top: '50%',
          'margin-left': '-25px',
          'margin-top': '-15px',
        })),
      ]
    );
    BODY.appendChild(container);

    await matchScreenshot();
  });
  it('container-dynamic-002', async () => {
    let block;
    let target;
    let intermediate;
    let container;
    container = create(
      'div',
      {
        position: 'relative',
      },
      [
        (intermediate = create(
          'div',
          {
            overflow: 'hidden',
            width: '200px',
            height: '200px',
            'background-color': 'red',
          },
          [
            (block = create('div', {
              height: '200px',
              'background-color': 'green',
            })),
            (target = create('div', {
              position: 'absolute',
              width: '200px',
              height: '100px',
              'background-color': 'green',
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await matchScreenshot();
  });
  it('container-dynamic', async () => {
    let target;
    let container;
    container = create(
      'div',
      {
        position: 'relative',
        width: '50px',
        height: '100px',
        'background-color': 'red',
      },
      [
        create(
          'div',
          {
            display: 'flex',
          },
          [
            (target = create('div', {
              position: 'absolute',
              left: '0',
              width: '50px',
              height: '100px',
              'background-color': 'green',
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(container);

    await matchScreenshot();
  });
  it('crash-chrome-003', async () => {
    let fixed;
    let abs;
    let abs_1;
    let flex;
    abs_1 = create(
      'div',
      {
        position: 'absolute',
      },
      [
        (flex = create(
          'div',
          {
            display: 'flex',
          },
          [
            (abs = create(
              'div',
              {
                position: 'absolute',
              },
              [
                (fixed = create('div', {
                  position: 'fixed',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(abs);
    BODY.appendChild(abs_1);

    await matchScreenshot();
  });
  xit('crash-chrome-007', async () => {
    let splitter;
    let abs;
    let fullabs;
    let cssContainer;
    let anonymousSplit;
    let anonymousParent;
    let blockContainer;
    blockContainer = create(
      'div',
      {
        position: 'relative',
      },
      [
        (anonymousParent = create(
          'span',
          {
            'background-color': '#FFFF7F',
          },
          [
            createText(`parent start`),
            (anonymousSplit = create(
              'span',
              {
                'background-color': '#FFD997',
              },
              [
                createText(`split start`),
                (splitter = create('div', {}, [createText(`splitter`)])),
                createText(`split middle`),
                (cssContainer = create(
                  'span',
                  {
                    position: 'relative',
                    'font-size': '12px',
                    'background-color': '#BEE0FF',
                  },
                  [
                    createText(`css-container start`),
                    (abs = create(
                      'div',
                      {
                        'background-color': 'rgba(0, 255, 0, 0.5)',
                        position: 'absolute',
                        top: '0px',
                        left: '0px',
                      },
                      [createText(`ABS`)]
                    )),
                    (fullabs = create(
                      'div',
                      {
                        'background-color': 'rgba(0, 255, 0, 0.5)',
                        position: 'absolute',
                        top: '0',
                        left: '0',
                        bottom: '0',
                        right: '0',
                      },
                      [createText(`FULLABS`)]
                    )),
                    createText(`css container end`),
                  ]
                )),
                createText(`split end`),
              ]
            )),
            createText(`parent end`),
          ]
        )),
      ]
    );
    BODY.appendChild(blockContainer);

    await matchScreenshot();
  });
  it('crash-chrome-012', async () => {
    let target;
    let container;
    container = create(
      'div',
      {
        width: '600px',
        position: 'relative',
      },
      [
        (target = create('div', {
          position: 'absolute',
          left: '0px',
          right: '33554000px',
          width: '10px',
          'margin-left': '33554432px',
          'margin-right': '33554432px',
          height: '20px',
        })),
      ]
    );
    BODY.appendChild(container);

    await matchScreenshot();
  });
  it('dynamic-containing-block', async () => {
    let target;
    let noLayout1;
    let noLayout2;
    let intermediate;
    let outer;
    outer = create(
      'div',
      {
        width: '400px',
        height: '300px',
        border: '1px solid black',
        padding: '5px',
      },
      [
        create(
          'div',
          {
            padding: '5px',
          },
          [
            (intermediate = create(
              'div',
              {
                width: '300px',
                height: '200px',
                border: '1px solid gray',
                padding: '5px',
              },
              [
                create(
                  'div',
                  {
                    padding: '5px',
                  },
                  [
                    (target = create(
                      'div',
                      {
                        'background-color': 'green',
                        padding: '5px',
                      },
                      [createText(`TTT`)]
                    )),
                    (noLayout1 = create('div', {
                      padding: '5px',
                    })),
                  ]
                ),
                (noLayout2 = create('div', {
                  padding: '5px',
                })),
              ]
            )),
          ]
        ),
      ]
    );
    BODY.appendChild(outer);

    await matchScreenshot();
  });
  xit('dynamic-list-marker', async () => {
    let p;
    let target;
    let ul;
    p = create('p', {}, [
      createText(`Test passes if there is a filled green square.`),
    ]);
    ul = create(
      'ul',
      {
        margin: '0',
        padding: '0',
        width: '100px',
        height: '100px',
        'background-color': 'red',
      },
      [
        create(
          'li',
          {
            position: 'relative',
          },
          [
            create('div', {
              height: '50px',
            }),
            (target = create('div', {
              position: 'absolute',
              width: '100px',
              height: '100px',
              'background-color': 'green',
              top: '0px',
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(ul);

    await matchScreenshot();

    target.style.top = '0px';

    await matchScreenshot();
  });
  it('dynamic-overflow-001', async () => {
    let div;
    let target;
    let container;
    div = create('div', {}, [
      createText(`Test passes if there is a filled green square.`),
    ]);
    container = create(
      'div',
      {
        position: 'relative',
        'background-color': 'red',
        'box-sizing': 'border-box',
        width: '100px',
        'max-height': '100px',
        overflow: 'auto',
      },
      [
        (target = create('div', {
          position: 'absolute',
          width: '50px',
          height: '50px',
        })),
        create('div', {
          height: '100px',
          'background-color': 'green',
        }),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(container);

    await matchScreenshot();

    target.style.width = '50px';
    target.style.height = '50px';

    await matchScreenshot();
  });
  it('dynamic-overflow-002', async () => {
    let div;
    let target;
    let container;
    let scrollable;
    let green;
    div = create('div', {}, [
      createText(`Test passes if there is a filled green square.`),
    ]);
    scrollable = create(
      'div',
      {
        width: '100px',
        overflow: 'auto',
      },
      [
        (container = create(
          'div',
          {
            width: '100px',
            height: '50px',
            position: 'relative',
            'background-color': 'green',
          },
          [
            (target = create('div', {
              position: 'absolute',
              width: '50px',
              height: '20px',
              left: 'initial',
            })),
          ]
        )),
      ]
    );
    green = create('div', {
      width: '100px',
      height: '50px',
      'background-color': 'green',
    });
    BODY.appendChild(div);
    BODY.appendChild(scrollable);
    BODY.appendChild(green);

    await matchScreenshot();
    target.style.left = 'initial';

    await matchScreenshot();
  });
  it('dynamic-relayout-001', async () => {
    let p;
    let target1;
    let target2;
    let div;
    p = create('p', {}, [
      createText(`Test passes if there is a filled green square.`),
    ]);
    div = create(
      'div',
      {
        display: 'flex',
        width: '100px',
        height: '100px',
        overflow: 'hidden',
        position: 'relative',
      },
      [
        create(
          'div',
          {
            position: 'relative',
          },
          [
            create(
              'div',
              {
                display: 'flex',
                position: 'relative',
                width: '100px',
                height: '50px',
                overflow: 'hidden',
              },
              [
                (target1 = create('div', {
                  position: 'absolute',
                  width: '100px',
                  height: '50px',
                  'background-color': 'green',
                })),
              ]
            ),
            (target2 = create('div', {
              position: 'absolute',
              width: '100px',
              height: '50px',
              'background-color': 'green',
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await matchScreenshot();

    target2.style.width = '100px';
    target1.style.width = '100px';

    await matchScreenshot();
  });
  it('dynamic-relayout-002', async () => {
    let target;
    target = create(
      'div',
      {
        position: 'relative',
        'background-color': 'red',
        margin: '0px',
        width: '50px',
        height: '50px',
        border: '25px solid green',
      },
      [
        create('div', {
          position: 'absolute',
          top: '0',
          left: '0',
          width: '50px',
          height: '50px',
          'background-color': 'green',
        }),
      ]
    );
    BODY.appendChild(target);

    await matchScreenshot();
    target.style.border = '25px solid green';
    target.style.margin = '0';

    await matchScreenshot();
  });
  xit('dynamic-static-position-inline', async () => {
    let target;
    let div;
    div = create(
      'div',
      {
        position: 'relative',
        'line-height': '0',
      },
      [
        create('div', {
          width: '100px',
          height: '50px',
          display: 'inline-block',
          'background-color': 'green',
        }),
        (target = create('div', {
          width: '100px',
          height: '50px',
          display: 'block',
          position: 'absolute',
          'background-color': 'green',
        })),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
    target.style.display = 'block';

    await matchScreenshot();

    await matchScreenshot();
  });
  it('dynamic-static-position-margin-001', async () => {
    let p;
    let block;
    let target;
    let cover;
    let container;
    p = create('p', {}, [
      createText(`Test passes if there is a filled green square.`),
    ]);
    container = create(
      'div',
      {
        position: 'relative',
        'background-color': 'red',
        'box-sizing': 'border-box',
        border: '10px solid green',
        width: '100px',
        height: '100px',
      },
      [
        (block = create('div', {
          'background-color': 'green',
          height: '40px',
          'margin-bottom': '20px',
        })),
        (target = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '20px',
          top: 'initial',
          left: 'initial',
        })),
        (cover = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '20px',
          top: '40px',
          left: '0px',
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await matchScreenshot();
  });
  it('dynamic-static-position-margin-002', async () => {
    let p;
    let block;
    let target;
    let cover;
    let container;
    p = create('p', {}, [
      createText(`Test passes if there is a filled green square.`),
    ]);
    container = create(
      'div',
      {
        position: 'relative',
        'background-color': 'red',
        'box-sizing': 'border-box',
        border: 'solid green 10px',
        width: '100px',
        height: '100px',
      },
      [
        create('div', {}, [
          (block = create('div', {
            'background-color': 'green',
            height: '40px',
            'margin-bottom': '20px',
          })),
        ]),
        (target = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '20px',
          top: 'initial',
          left: 'initial',
        })),
        (cover = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '20px',
          top: '40px',
          left: '0px',
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await matchScreenshot();

    target.style.top = 'initial';
    target.style.left = 'initial';

    await matchScreenshot();
  });
  it('dynamic-static-position', async () => {
    let p;
    let target;
    let container;
    p = create('p', {}, [
      createText(`Test passes if there is a filled green square.`),
    ]);
    container = create(
      'div',
      {
        position: 'relative',
        'background-color': 'red',
        'box-sizing': 'border-box',
        border: 'solid green 10px',
        width: '100px',
        height: '100px',
      },
      [
        (target = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '80px',
          top: 'initial',
          left: 'initial',
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await matchScreenshot();
    target.style.top = 'initial';
    target.style.left = 'initial';

    await matchScreenshot();
  });
});
