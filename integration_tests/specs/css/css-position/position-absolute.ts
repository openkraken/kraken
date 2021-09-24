/*auto generated*/
describe('position-absolute', () => {
  it('001', async () => {
    let p;
    let div2;
    let div3;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '100px',
            width: '100px',
            background: 'green',
            position: 'absolute',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            height: '100px',
            width: '100px',
            background: 'red',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('002-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if an orange square fills the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`bottom-right corner`)]
        ),
        createText(` of a bigger blue square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'blue',
          height: '192px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/swatch-orange.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            padding: '96px 0 0 96px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('002', async () => {
    let p;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if an orange square fills the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`bottom-right corner`)]
        ),
        createText(` of a bigger blue square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          background: 'blue',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'orange',
            bottom: '0',
            left: '96px',
            position: 'absolute',
            right: '0',
            top: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let div2;
    let div3;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '100px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '100px',
            width: '100px',
            background: 'red',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            height: '100px',
            width: '100px',
            background: 'green',
            position: 'absolute',
            left: '0',
            top: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('004-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if the blue square is directly below the orange square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'blue',
          height: '192px',
          'margin-left': '96px',
          width: '96px',
        },
      },
      [
        createElement('img', {
          src: 'assets/swatch-orange.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('004', async () => {
    let p;
    let div3;
    let div2;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if the blue square is directly below the orange square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              height: '192px',
              width: '96px',
              background: 'blue',
              left: '96px',
              position: 'absolute',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                height: '96px',
                width: '96px',
                background: 'orange',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('005', async () => {
    let p;
    let div3;
    let div2;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-top': '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a box in the upper-left corner of the page.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              position: 'absolute',
              height: '96px',
              left: '288px',
              top: '288px',
              width: '96px',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                background: 'black',
                height: '96px',
                left: '0',
                position: 'fixed',
                top: '0',
                width: '96px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('006', async () => {
    let p;
    let div3;
    let div2;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if the blue square is directly below the orange square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              height: '96px',
              width: '96px',
              background: 'orange',
              left: '96px',
              position: 'absolute',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                height: '96px',
                width: '96px',
                background: 'blue',
                position: 'relative',
                top: '96px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('007-ref', async () => {
    let p;
    let blue;
    let blue_1;
    let orange;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if the "Filler Text" overflow below the orange square and overlaps the bottom blue square.`
        ),
      ]
    );
    blue = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'blue',
      style: {
        'background-color': 'blue',
        height: '48px',
        width: '48px',
      },
    });
    orange = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'orange',
        style: {
          'background-color': 'orange',
          height: '96px',
          width: '96px',
        },
      },
      [
        createText(
          `Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text`
        ),
      ]
    );
    blue_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'blue',
      style: {
        'background-color': 'blue',
        height: '48px',
        width: '48px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(blue);
    BODY.appendChild(blue_1);
    BODY.appendChild(orange);

    await snapshot();
  });
  it('007', async () => {
    let p;
    let div2;
    let div3;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if the "Filler Text" overflow below the orange square and overlaps the bottom blue square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              background: 'orange',
              position: 'absolute',
              height: '96px',
              top: '48px',
              width: '96px',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
                Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text Filler Text
            `),
          ]
        )),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            background: 'blue',
            float: 'left',
            height: '192px',
            width: '48px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('008', async () => {
    let p;
    let div2;
    let div3;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '100px',
            width: '100px',
            background: 'red',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            height: '100px',
            width: '100px',
            background: 'green',
            float: 'right',
            position: 'absolute',
            top: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });

  it('should work with nested parent', async () => {
    let item;
    let flex;
    let container = createElement(
      'div', {
        style: {
          'box-sizing': 'border-box',
        }
      }
    );
    flex = createElement(
      'div',
      {
        id: 'flex',
        style: {
          display: 'flex',
          position: 'relative',
          background: 'red',
          flexShrink: 0,
          minWidth: 0,
          height: '200px',
          padding: '123px 0 0',
          'box-sizing': 'border-box',
          transformOrigin: 'center',
        },
      },
      [
        (item = createElement('div', {
          id: 'item',
          style: {
            position: 'absolute',
            width: '50px',
            height: '50px',
            left: '20px',
            background: 'green',
            transformOrigin: 'center',
          },
        }
        )),
      ]
    );
    BODY.appendChild(container);
    container.appendChild(flex);

    await snapshot();
  });
});
