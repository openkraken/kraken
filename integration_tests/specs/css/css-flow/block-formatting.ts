/*auto generated*/
describe('block-formatting', () => {
  it('context-height-001', async () => {
    let p;
    let float;
    let container;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a filled black square.`)]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'container',
        style: {
          width: '96px',
          height: 'auto',
          background: 'black',
          position: 'absolute',
          'box-sizing': 'border-box',
        },
      },
      [
        (float = createElement('div', {
          id: 'float',
          style: {
            float: 'left',
            'margin-bottom': '48px',
            height: '48px',
            width: '100%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('context-height-003-ref', async () => {
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
          `Test passes if there is a black rectangle which is wider than it is tall.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'black',
        height: '50px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('context-height-003', async () => {
    let p;
    let sibling;
    let float;
    let absolute;
    let container;
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
          `Test passes if there is a black rectangle which is wider than it is tall.`
        ),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'container',
        style: {
          width: '100px',
          height: 'auto',
          background: 'black',
          position: 'absolute',
          'box-sizing': 'border-box',
        },
      },
      [
        (sibling = createElement('div', {
          id: 'sibling',
          style: {
            height: '50px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
        (absolute = createElement(
          'div',
          {
            id: 'absolute',
            style: {
              position: 'absolute',
              width: '100px',
              height: '50px',
              'box-sizing': 'border-box',
            },
          },
          [
            (float = createElement('div', {
              id: 'float',
              style: {
                'margin-bottom': '50px',
                height: '50px',
                width: '100%',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('contexts-001', async () => {
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
      [createText(`Test passes if there are 3 lines of "Filler Text".`)]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('contexts-004-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom': 'black solid 20px',
        'border-top': 'black solid 20px',
        height: '40px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('contexts-005-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`no space between`)]
        ),
        createText(` the blue and orange lines.`),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'blue',
        'border-right': '5px solid orange',
        height: '96px',
        width: '5px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('contexts-005', async () => {
    let div1;
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '100px',
          'border-left': '5px solid blue',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            'border-left': '5px solid orange',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(div1);

    await snapshot();
  });
  it('contexts-006-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`no space between`)]
        ),
        createText(` the blue and orange lines.`),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'orange',
        'border-right': '5px solid blue',
        height: '96px',
        'margin-left': '91px',
        width: '5px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('contexts-006', async () => {
    let child;
    let div1;
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '100px',
          'border-right': '5px solid blue',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('div', {
          id: 'child',
          style: {
            height: '100px',
            'border-right': '5px solid orange',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(div1);

    await snapshot();
  });
  it('contexts-008-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the upper-half of the square is blue.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          height: '400px',
          width: '200px',
        },
      },
      [
        createElement('img', {
          src: 'assets/200x200-green.png',
          width: '200',
          height: '100',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.2);
  });
  it('contexts-009', async () => {
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
      [createText(`Test passes if the upper-half of the square is blue.`)]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'absolute',
          border: 'solid',
          height: '200px',
          width: '200px',
          background: 'blue',
          display: 'inline',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            display: 'inline',
            height: '50%',
            width: '100%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('contexts-010', async () => {
    let p;
    let blockDescendant;
    let blockDescendant_1;
    let blockFormattingContext;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the upper-half of the square is blue.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        (blockFormattingContext = createElement(
          'span',
          {
            id: 'block-formatting-context',
            style: {
              border: 'black solid medium',
              display: 'inline-block',
              height: '200px',
              width: '200px',
            },
          },
          [
            (blockDescendant = createElement('span', {
              class: 'block-descendant',
              style: {
                'background-color': 'blue',
                display: 'block',
                height: '25%',
                width: '100%',
              },
            })),
            (blockDescendant_1 = createElement('span', {
              class: 'block-descendant',
              style: {
                'background-color': 'blue',
                display: 'block',
                height: '25%',
                width: '100%',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('contexts-015-ref', async () => {
    let p;
    let div;
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
          `Test passes if the blue and orange squares have the same size.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '50',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          width: '50',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
});
