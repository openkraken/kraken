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
        'box-sizing': 'border-box',
        'flex-direction': 'row',
      },
      [
        (innerFlex = create(
          'div',
          {
            'flex-grow': '1',
            display: 'flex',
            'justify-content': 'center',
            'box-sizing': 'border-box',
            margin: '10px',
            height: '100px',
          },
          [
            create(
              'div',
              {
                'box-sizing': 'border-box',
                position: 'absolute',
                top: '0',
                height: '100px',
                'background-color': 'green',
              },
              [
                create('span', {
                  display: 'inline-block',
                  width: '50px',
                  'box-sizing': 'border-box',
                }),
                create('span', {
                  display: 'inline-block',
                  width: '50px',
                  'box-sizing': 'border-box',
                }),
              ]
            ),
          ]
        )),
        create('div', {
          'flex-grow': '1',
          'box-sizing': 'border-box',
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
        'box-sizing': 'border-box',
        'flex-direction': 'column',
      },
      [
        (innerFlex = create(
          'div',
          {
            'flex-grow': '1',
            display: 'flex',
            'align-items': 'center',
            'box-sizing': 'border-box',
            margin: '10px',
            width: '100px',
          },
          [
            create(
              'div',
              {
                'box-sizing': 'border-box',
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
                  'box-sizing': 'border-box',
                }),
                create('span', {
                  display: 'inline-block',
                  height: '50px',
                  width: '50px',
                  'box-sizing': 'border-box',
                }),
              ]
            ),
          ]
        )),
        create('div', {
          'flex-grow': '1',
          'box-sizing': 'border-box',
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
        'box-sizing': 'border-box',
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
          'box-sizing': 'border-box',
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
        'box-sizing': 'border-box',
      },
      [
        (intermediate = create(
          'div',
          {
            overflow: 'hidden',
            width: '200px',
            height: '200px',
            'background-color': 'red',
            'box-sizing': 'border-box',
          },
          [
            (block = create('div', {
              height: '200px',
              'background-color': 'green',
              'box-sizing': 'border-box',
            })),
            (target = create('div', {
              position: 'absolute',
              width: '200px',
              height: '100px',
              'background-color': 'green',
              'box-sizing': 'border-box',
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
        'box-sizing': 'border-box',
      },
      [
        create(
          'div',
          {
            'box-sizing': 'border-box',
            display: 'flex',
          },
          [
            (target = create('div', {
              position: 'absolute',
              left: '0',
              width: '50px',
              height: '100px',
              'background-color': 'green',
              'box-sizing': 'border-box',
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
        'box-sizing': 'border-box',
      },
      [
        (flex = create(
          'div',
          {
            display: 'flex',
            'box-sizing': 'border-box',
          },
          [
            (abs = create(
              'div',
              {
                position: 'absolute',
                'box-sizing': 'border-box',
              },
              [
                (fixed = create('div', {
                  position: 'fixed',
                  'box-sizing': 'border-box',
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
  it('crash-chrome-004', async () => {
    let fixed2;
    let fixed1;
    let flex;
    let flex_1;
    let abs;
    let one;
    one = create(
      'div',
      {
        position: 'relative',
        'box-sizing': 'border-box',
      },
      [
        (flex_1 = create(
          'div',
          {
            display: 'flex',
            'box-sizing': 'border-box',
          },
          [
            (abs = create(
              'div',
              {
                position: 'absolute',
                'box-sizing': 'border-box',
              },
              [
                (flex = create(
                  'div',
                  {
                    display: 'flex',
                    'box-sizing': 'border-box',
                  },
                  [
                    (fixed1 = create(
                      'div',
                      {
                        position: 'fixed',
                        'box-sizing': 'border-box',
                      },
                      [
                        (fixed2 = create('div', {
                          position: 'fixed',
                          'box-sizing': 'border-box',
                        })),
                      ]
                    )),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(one);

    await matchScreenshot();
  });
  it('crash-chrome-005', async () => {
    let abs;
    let intermediate;
    let boundary;
    let boundary_1;
    let boundary_2;
    let one;
    one = create(
      'div',
      {
        position: 'relative',
        'box-sizing': 'border-box',
      },
      [
        (boundary_2 = create(
          'div',
          {
            overflow: 'hidden',
            width: '100px',
            height: '100px',
            'box-sizing': 'border-box',
          },
          [
            (boundary_1 = create(
              'div',
              {
                overflow: 'hidden',
                width: '100px',
                height: '100px',
                'box-sizing': 'border-box',
              },
              [
                (boundary = create(
                  'div',
                  {
                    overflow: 'hidden',
                    width: '100px',
                    height: '100px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (intermediate = create(
                      'div',
                      {
                        animation: 'slidein 0.1s linear',
                        'box-sizing': 'border-box',
                      },
                      [
                        (abs = create('div', {
                          position: 'absolute',
                          width: '50px',
                          height: '50px',
                          'background-color': 'green',
                          'box-sizing': 'border-box',
                        })),
                      ]
                    )),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(one);

    await matchScreenshot();
  });
  it('crash-chrome-006', async () => {
    let parent;
    let boundary;
    boundary = create(
      'div',
      {
        overflow: 'hidden',
        width: '100px',
        height: '100px',
        'box-sizing': 'border-box',
      },
      [
        (parent = create('div', {
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(boundary);

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
        'box-sizing': 'border-box',
      },
      [
        (anonymousParent = create(
          'span',
          {
            'background-color': '#FFFF7F',
            'box-sizing': 'border-box',
          },
          [
            createText(`parent start`),
            (anonymousSplit = create(
              'span',
              {
                'background-color': '#FFD997',
                'box-sizing': 'border-box',
              },
              [
                createText(`split start`),
                (splitter = create(
                  'div',
                  {
                    'box-sizing': 'border-box',
                  },
                  [createText(`splitter`)]
                )),
                createText(`split middle`),
                (cssContainer = create(
                  'span',
                  {
                    position: 'relative',
                    'font-size': '12px',
                    'background-color': '#BEE0FF',
                    'box-sizing': 'border-box',
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
                        'box-sizing': 'border-box',
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
                        'box-sizing': 'border-box',
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
  it('crash-chrome-008', async () => {
    let span;
    span = create(
      'span',
      {
        'box-sizing': 'border-box',
        'border-bottom': '1px solid',
        filter: 'blur(2px)',
      },
      [
        create('div', {
          'box-sizing': 'border-box',
          position: 'absolute',
        }),
      ]
    );
    BODY.appendChild(span);

    await matchScreenshot();
  });
  it('crash-chrome-009', async () => {
    let target;
    let fixedContainer;
    let inlineFixedContainer;
    let container;
    container = create(
      'div',
      {
        position: 'relative',
        overflow: 'auto',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (inlineFixedContainer = create(
          'span',
          {
            filter: 'url("")',
            'box-sizing': 'border-box',
          },
          [
            (fixedContainer = create(
              'div',
              {
                position: 'fixed',
                'box-sizing': 'border-box',
              },
              [
                (target = create('div', {
                  position: 'fixed',
                  'box-sizing': 'border-box',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await matchScreenshot();
  });
  it('crash-chrome-010', async () => {
    let target;
    let fixedContainer;
    let inlineFixedContainer;
    let container;
    container = create(
      'div',
      {
        position: 'relative',
        overflow: 'auto',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (inlineFixedContainer = create(
          'span',
          {
            filter: 'url("")',
            'box-sizing': 'border-box',
          },
          [
            (fixedContainer = create(
              'div',
              {
                position: 'fixed',
                'box-sizing': 'border-box',
              },
              [
                (target = create('div', {
                  position: 'fixed',
                  'box-sizing': 'border-box',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

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
        'box-sizing': 'border-box',
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
          'box-sizing': 'border-box',
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
        'box-sizing': 'border-box',
      },
      [
        create(
          'div',
          {
            padding: '5px',
            'box-sizing': 'border-box',
          },
          [
            (intermediate = create(
              'div',
              {
                width: '300px',
                height: '200px',
                border: '1px solid gray',
                padding: '5px',
                'box-sizing': 'border-box',
              },
              [
                create(
                  'div',
                  {
                    padding: '5px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (target = create(
                      'div',
                      {
                        'background-color': 'green',
                        padding: '5px',
                        'box-sizing': 'border-box',
                      },
                      [createText(`TTT`)]
                    )),
                    (noLayout1 = create('div', {
                      padding: '5px',
                      'box-sizing': 'border-box',
                    })),
                  ]
                ),
                (noLayout2 = create('div', {
                  padding: '5px',
                  'box-sizing': 'border-box',
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
    p = create(
      'p',
      {
        'box-sizing': 'border-box',
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
    ul = create(
      'ul',
      {
        margin: '0',
        padding: '0',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        'box-sizing': 'border-box',
      },
      [
        create(
          'li',
          {
            'box-sizing': 'border-box',
            position: 'relative',
          },
          [
            create('div', {
              'box-sizing': 'border-box',
              height: '50px',
            }),
            (target = create('div', {
              position: 'absolute',
              width: '100px',
              height: '100px',
              'background-color': 'green',
              'box-sizing': 'border-box',
              top: '0px',
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(ul);

    target.style.top = '0px';

    await matchScreenshot();
  });
  xit('dynamic-overflow-001', async () => {
    let div;
    let target;
    let container;
    div = create(
      'div',
      {
        'box-sizing': 'border-box',
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
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
          'box-sizing': 'border-box',
        })),
        create('div', {
          'box-sizing': 'border-box',
          height: '100px',
          'background-color': 'green',
        }),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(container);

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
    div = create(
      'div',
      {
        'box-sizing': 'border-box',
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
    scrollable = create(
      'div',
      {
        width: '100px',
        overflow: 'auto',
        'box-sizing': 'border-box',
      },
      [
        (container = create(
          'div',
          {
            width: '100px',
            height: '50px',
            position: 'relative',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
          [
            (target = create('div', {
              position: 'absolute',
              width: '50px',
              height: '20px',
              left: 'initial',
              'box-sizing': 'border-box',
            })),
          ]
        )),
      ]
    );
    green = create('div', {
      width: '100px',
      height: '50px',
      'background-color': 'green',
      'box-sizing': 'border-box',
    });
    BODY.appendChild(div);
    BODY.appendChild(scrollable);
    BODY.appendChild(green);

    target.style.left = 'initial';

    await matchScreenshot();
  });
  it('dynamic-relayout-001', async () => {
    let p;
    let target1;
    let target2;
    let div;
    p = create(
      'p',
      {
        'box-sizing': 'border-box',
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
    div = create(
      'div',
      {
        'box-sizing': 'border-box',
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
            'box-sizing': 'border-box',
            position: 'relative',
          },
          [
            create(
              'div',
              {
                'box-sizing': 'border-box',
                display: 'flex',
                position: 'relative',
                width: '100px',
                height: '50px',
                overflow: 'hidden',
              },
              [
                (target1 = create('div', {
                  'box-sizing': 'border-box',
                  position: 'absolute',
                  width: '100px',
                  height: '50px',
                  'background-color': 'green',
                })),
              ]
            ),
            (target2 = create('div', {
              'box-sizing': 'border-box',
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

    target2.style.width = '100px';
    target1.style.width = '100px';

    await matchScreenshot();
  });
  xit('dynamic-relayout-002', async () => {
    let target;
    target = create(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        'background-color': 'red',
        margin: '0px',
        width: '50px',
        height: '50px',
        border: '25px solid green',
      },
      [
        create('div', {
          'box-sizing': 'border-box',
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

    target.style.border = '25px solid green';
    target.style.margin = '0';

    await matchScreenshot();
  });
  it('dynamic-static-position-inline', async () => {
    let target;
    let div;
    div = create(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        'line-height': '0',
      },
      [
        create('div', {
          'box-sizing': 'border-box',
          width: '100px',
          height: '50px',
          display: 'inline-block',
          'background-color': 'green',
        }),
        (target = create('div', {
          'box-sizing': 'border-box',
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
  });
  it('dynamic-static-position-margin-001', async () => {
    let p;
    let block;
    let target;
    let cover;
    let container;
    p = create(
      'p',
      {
        'box-sizing': 'border-box',
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
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
          'box-sizing': 'border-box',
        })),
        (target = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '20px',
          top: 'initial',
          left: 'initial',
          'box-sizing': 'border-box',
        })),
        (cover = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '20px',
          top: '40px',
          left: '0px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    target.style.top = 'initial';
    target.style.left = 'initial';

    await matchScreenshot();
  });
  it('dynamic-static-position-margin-002', async () => {
    let p;
    let block;
    let target;
    let cover;
    let container;
    p = create(
      'p',
      {
        'box-sizing': 'border-box',
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
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
        create(
          'div',
          {
            'box-sizing': 'border-box',
          },
          [
            (block = create('div', {
              'background-color': 'green',
              height: '40px',
              'margin-bottom': '20px',
              'box-sizing': 'border-box',
            })),
          ]
        ),
        (target = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '20px',
          top: 'initial',
          left: 'initial',
          'box-sizing': 'border-box',
        })),
        (cover = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '20px',
          top: '40px',
          left: '0px',
          'box-sizing': 'border-box',
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
    p = create(
      'p',
      {
        'box-sizing': 'border-box',
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
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
        (target = create('div', {
          position: 'absolute',
          'background-color': 'green',
          width: '80px',
          height: '80px',
          top: '0',
          left: '0',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await matchScreenshot();

    target.style.top = '0';
    target.style.left = '0';

    await matchScreenshot();
  });
  it('in-inline-001', async () => {
    let target;
    let container;
    container = create(
      'span',
      {
        'box-sizing': 'border-box',
        position: 'relative',
      },
      [
        create('div', {
          'box-sizing': 'border-box',
          width: '100px',
          height: '100px',
          'background-color': 'red',
        }),
        (target = create('div', {
          'box-sizing': 'border-box',
          position: 'absolute',
          left: '0',
          top: '0',
          width: '100px',
          height: '100px',
          'background-color': 'green',
        })),
      ]
    );
    BODY.appendChild(container);

    await matchScreenshot();
  });
  it('in-inline-002', async () => {
    let split;
    let containerSpan;
    let outerSpan;
    outerSpan = create(
      'span',
      {
        'box-sizing': 'border-box',
      },
      [
        createText(`outer span`),
        (containerSpan = create(
          'span',
          {
            position: 'relative',
            border: '1px solid gray',
            'box-sizing': 'border-box',
          },
          [
            createText(`container span start`),
            (split = create('div', {
              width: '10px',
              height: '10px',
              'box-sizing': 'border-box',
            })),
            createText(`container span end`),
          ]
        )),
        createText(`outer span end`),
      ]
    );
    BODY.appendChild(outerSpan);

    await matchScreenshot();
  });
  it('in-inline-crash', async () => {
    let target;
    let split;
    let container;
    container = create(
      'div',
      {
        'box-sizing': 'border-box',
      },
      [
        (split = create(
          'span',
          {
            'box-sizing': 'border-box',
            position: 'relative',
            color: 'green',
          },
          [
            createText(`AAA`),
            create(
              'div',
              {
                'box-sizing': 'border-box',
                display: 'flex',
              },
              [
                create(
                  'span',
                  {
                    'box-sizing': 'border-box',
                  },
                  [
                    (target = create(
                      'span',
                      {
                        'box-sizing': 'border-box',
                        position: 'absolute',
                        color: 'green',
                        top: '20px',
                      },
                      [createText(`XXX`)]
                    )),
                  ]
                ),
              ]
            ),
            createText(`ZZZ`),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await matchScreenshot();
  });
  xit('percentage-height', async () => {
    let target;
    let imageWrapper;
    let contentWrapper;
    let container;
    container = create(
      'div',
      {
        position: 'relative',
        'box-sizing': 'border-box',
      },
      [
        (imageWrapper = create(
          'div',
          {
            display: 'flex',
            position: 'absolute',
            height: '100%',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
          [
            (target = create('img', {
              display: 'block',
              'min-height': '100%',
              opacity: '0.5',
              'box-sizing': 'border-box',
            })),
          ]
        )),
        (contentWrapper = create(
          'div',
          {
            'margin-left': '30%',
            'box-sizing': 'border-box',
          },
          [
            createText(
              `Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.`
            ),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await matchScreenshot();
  });
});
