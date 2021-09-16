/*auto generated*/
describe('absolute-replaced', () => {
  xit('height-001-ref', async () => {
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
        createText(` the blue square and the orange lines.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'border-bottom': '1px solid orange',
          'border-top': '1px solid orange',
          height: '15px',
          width: '96px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('height-001', async () => {
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
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no space between`)]
        ),
        createText(` the blue square and the orange lines.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'border-bottom': '1px solid orange',
          'border-top': '1px solid orange',
          height: '15px',
          width: '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            position: 'absolute',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('height-002-ref', async () => {
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
        createText(`Test passes if the blue and orange squares have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same height`)]
        ),
        createText(`.`),
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
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
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
  xit('height-002', async () => {
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
        createText(`Test passes if the blue and orange squares have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same height`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            height: 'auto',
            position: 'absolute',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'orange',
            height: '15px',
            left: '15px',
            top: '0',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('height-003', async () => {
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
        createText(`Test passes if the orange and blue squares have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same height`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'Image download support must be enabled',
          src: 'assets/swatch-orange.png',
          style: {
            height: 'auto',
            position: 'absolute',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            height: '100px',
            left: '100px',
            top: '0',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('height-004-ref', async () => {
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
        border: '1px solid green',
        height: '150px',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('height-004', async () => {
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
        createText(`Test passes if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          style: {
            border: '1px solid red',
            height: 'auto',
            position: 'absolute',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            position: 'absolute',
            border: '1px solid green',
            height: '150px',
            top: '0',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('height-005-ref', async () => {
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
        border: '1px solid green',
        height: '96px',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('height-005', async () => {
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
        createText(`Test passes if there is `),
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
          height: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            position: 'absolute',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            height: '96px',
            position: 'absolute',
            top: '0',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('height-006-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if the blue and orange rectangles have the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`same height`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '96px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '96px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('height-007-ref', async () => {
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
        border: '1px solid green',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('height-007', async () => {
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
        createText(`Test passes if there is `),
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
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            position: 'absolute',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            position: 'absolute',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('height-008-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if there is a short blue bar and it does not touch the black line.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-top': '1px solid black',
        'margin-bottom': '96px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-top': '1px none 0px',
        'margin-bottom': '96px',
        'background-color': 'blue',
        height: '15px',
        width: '30px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  xit('height-008', async () => {
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
        createText(
          `Test passes if there is a short blue bar and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: 'auto',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '15px',
            left: '15px',
            position: 'relative',
            top: '96px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-009', async () => {
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
        createText(
          `Test passes if there is a short blue bar and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: 'auto',
            height: 'auto',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '15px',
            left: '15px',
            position: 'absolute',
            top: '96px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('height-010-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if there is a filled blue rectangle and it does not touch the black line.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-top': '1px solid black',
        'margin-bottom': '96px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-top': '1px none 0px',
        'margin-bottom': '96px',
        'background-color': 'blue',
        height: '96px',
        width: '192px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  xit('height-010', async () => {
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
        createText(
          `Test passes if there is a filled blue rectangle and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: 'auto',
            height: 'auto',
            position: 'absolute',
            top: '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '96px',
            left: '96px',
            position: 'absolute',
            top: '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('height-011-ref', async () => {
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
        border: '1px solid green',
        height: '150px',
        'margin-top': '112px',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('height-011', async () => {
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
        createText(`Test passes if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          style: {
            border: '1px solid red',
            bottom: 'auto',
            height: 'auto',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            position: 'absolute',
            border: '1px solid green',
            height: '150px',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('height-012-ref', async () => {
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
        border: '1px solid green',
        height: '96px',
        'margin-top': '112px',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('height-012', async () => {
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
        createText(`Test passes if there is `),
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
          height: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            bottom: 'auto',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            height: '96px',
            position: 'absolute',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('height-013-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if the blue and orange rectangles are next to each other, have the same height and are not touching the black line.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-top': '1px solid black',
        'margin-bottom': '96px',
      },
    });
    div_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'border-top': '1px solid black',
          'margin-bottom': '96px',
          border: '1px none 0px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '96px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '96px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('height-014-ref', async () => {
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
        border: '1px solid green',
        'margin-top': '112px',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('height-014', async () => {
    let p;
    let containingBlock;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is `),
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
    containingBlock = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'containing-block',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            bottom: 'auto',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            position: 'absolute',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(containingBlock);

    await snapshot();
  });
  xit('height-016', async () => {
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
        createText(
          `Test passes if there is a short blue bar and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: '96px',
            height: 'auto',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '15px',
            left: '15px',
            position: 'absolute',
            top: '96px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-017', async () => {
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
        createText(
          `Test passes if there is a filled blue rectangle and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: '96px',
            height: 'auto',
            position: 'absolute',
            top: '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '96px',
            left: '96px',
            position: 'absolute',
            top: '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-018', async () => {
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
        createText(`Test passes if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          style: {
            border: '1px solid red',
            bottom: '96px',
            height: 'auto',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            position: 'absolute',
            border: '1px solid green',
            height: '150px',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('height-019', async () => {
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
        createText(`Test passes if there is `),
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
          height: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            bottom: '96px',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            height: '96px',
            position: 'absolute',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('height-021', async () => {
    let p;
    let containingBlock;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is `),
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
    containingBlock = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'containing-block',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            bottom: '96px',
            position: 'absolute',
            top: '96px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            position: 'absolute',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(containingBlock);

    await snapshot();
  });
  it('height-022', async () => {
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
        createText(
          `Test passes if there is a short blue bar and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: '96px',
            'margin-bottom': 'auto',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '15px',
            left: '15px',
            position: 'relative',
            top: '96px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-023', async () => {
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
        createText(
          `Test passes if there is a short blue bar and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: '96px',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '15px',
            left: '15px',
            position: 'absolute',
            top: '96px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-024', async () => {
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
        createText(
          `Test passes if there is a filled blue rectangle and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: '96px',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '96px',
            left: '96px',
            position: 'absolute',
            top: '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-025', async () => {
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
        createText(`Test passes if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          style: {
            border: '1px solid red',
            bottom: '96px',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            position: 'absolute',
            border: '1px solid green',
            height: '150px',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('height-026', async () => {
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
        createText(`Test passes if there is `),
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
          height: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            bottom: '96px',
            'margin-bottom': 'auto',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            height: '96px',
            position: 'absolute',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('height-028', async () => {
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
        createText(`Test passes if there is `),
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
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            bottom: '96px',
            'margin-bottom': 'auto',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            position: 'absolute',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('height-029', async () => {
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
        createText(
          `Test passes if there is a short blue bar and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: '48px',
            'margin-bottom': '48px',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '15px',
            left: '15px',
            position: 'relative',
            top: '96px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-030', async () => {
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
        createText(
          `Test passes if there is a short blue bar and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: '96px',
            height: 'auto',
            'margin-bottom': '48px',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '15px',
            left: '15px',
            position: 'absolute',
            top: '96px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-031', async () => {
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
        createText(
          `Test passes if there is a filled blue rectangle and it does not touch the black line.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-top': '1px solid black',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            bottom: '96px',
            height: 'auto',
            'margin-bottom': '48px',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'blue',
            height: '96px',
            left: '96px',
            position: 'absolute',
            top: '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('height-032', async () => {
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
        createText(`Test passes if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          style: {
            border: '1px solid red',
            bottom: '96px',
            height: 'auto',
            'margin-bottom': '48px',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            position: 'absolute',
            border: '1px solid green',
            height: '150px',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('height-033', async () => {
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
        createText(`Test passes if there is `),
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
          height: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            bottom: '96px',
            'margin-bottom': '48px',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            height: '96px',
            position: 'absolute',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('height-035', async () => {
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
        createText(`Test passes if there is `),
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
        createElement('iframe', {
          height: '50%',
          style: {
            border: '1px solid red',
            bottom: '96px',
            'margin-bottom': '48px',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            border: '1px solid green',
            position: 'absolute',
            top: '96px',
            width: '300px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('height-036', async () => {
    let p;
    let abspos;
    let abspos_1;
    let abspos_2;
    let control1;
    let control2;
    let control3;
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
        createText(`Test passes if there is `),
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
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          position: 'relative',
          width: '45px',
          height: '45px',
          'box-sizing': 'border-box',
        },
      },
      [
        (abspos = createElement('img', {
          class: 'abspos one',
          src: 'assets/swatch-white.png',
          alt: 'FAIL: image support required',
          style: {
            position: 'absolute',
            top: '0',
            bottom: '0',
            background: 'red',
            margin: 'auto',
            left: '0',
            'box-sizing': 'border-box',
          },
        })),
        (abspos_1 = createElement('img', {
          class: 'abspos two',
          src: 'assets/swatch-white.png',
          alt: 'FAIL: image support required',
          style: {
            position: 'absolute',
            top: '0',
            bottom: '0',
            background: 'red',
            'margin-top': 'auto',
            left: '15px',
            'box-sizing': 'border-box',
          },
        })),
        (abspos_2 = createElement('img', {
          class: 'abspos three',
          src: 'assets/swatch-white.png',
          alt: 'FAIL: image support required',
          style: {
            position: 'absolute',
            top: '0',
            bottom: '0',
            background: 'red',
            'margin-bottom': 'auto',
            right: '0',
            'box-sizing': 'border-box',
          },
        })),
        (control1 = createElement('div', {
          class: 'control1',
          style: {
            height: '15px',
            'border-right': '15px solid red',
            'box-sizing': 'border-box',
          },
        })),
        (control2 = createElement('div', {
          class: 'control2',
          style: {
            height: '15px',
            'border-left': '15px solid red',
            'box-sizing': 'border-box',
          },
        })),
        (control3 = createElement('div', {
          class: 'control3',
          style: {
            height: '15px',
            margin: '0 15px',
            background: 'red',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot(0.1);
  });
  it('width-001-ref', async () => {
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
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-left corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '192px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-001', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-left corner of an hollow black square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          height: '192px',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            position: 'absolute',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '15px',
            'margin-top': '15px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('width-002-ref', async () => {
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
          `Test passes if the blue and orange rectangles have the same width and the blue rectangle is in the upper-left corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '50px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '50px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-003-ref', async () => {
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
          `Test passes if the blue and orange rectangles have the same width and the blue rectangle is in the upper-left corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '100px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '100px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-003a-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a filled green rectangle and `),
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
        'background-color': 'green',
        height: '150px',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('width-003b-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a filled green square and `),
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
        'background-color': 'green',
        height: '150px',
        width: '150px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('width-003c-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a big filled green square and `),
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
        'background-color': 'green',
        height: '300px',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('width-004-ref', async () => {
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
          `Test passes if the blue and orange rectangles have the same width and the blue rectangle is in the upper-left corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '100px',
            'margin-bottom': '10px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            'margin-bottom': '10px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-006-ref', async () => {
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
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-left corner of an hollow black rectangle.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            width: '96px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            width: '96px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('width-006', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-left corner of an hollow black rectangle.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            position: 'absolute',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-008', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-left corner of an hollow black square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '192px',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: 'auto',
            position: 'absolute',
            right: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '15px',
            'margin-top': '15px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-013', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-left corner of an hollow black rectangle.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: 'auto',
            position: 'absolute',
            right: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-015-ref', async () => {
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
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '192px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            position: 'relative',
            left: '177px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            position: 'relative',
            left: '177px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('width-015', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: 'auto',
            position: 'absolute',
            right: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '15px',
            'margin-top': '15px',
            width: '15px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('width-020-ref', async () => {
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
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black rectangle.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            left: '96px',
            position: 'relative',
            width: '96px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            left: '96px',
            position: 'relative',
            width: '96px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('width-020', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black rectangle.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: 'auto',
            position: 'absolute',
            right: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('width-022-ref', async () => {
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
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '192px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            left: '96px',
            position: 'relative',
            width: '96px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            left: '96px',
            position: 'relative',
            width: '96px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-022', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 96x96',
          src: 'assets/blue96x96.png',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: '96px',
            position: 'absolute',
            right: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '96px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('width-023-ref', async () => {
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
          `Test passes if the blue and orange rectangles have the same width and the blue rectangle is in the upper-right corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '296px',
          width: '296px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '50px',
            'padding-left': '96px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '50px',
            'padding-left': '96px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-024-ref', async () => {
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
          `Test passes if the blue and orange rectangles have the same width and the blue rectangle is in the upper-right corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '100px',
            'padding-left': '88px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '100px',
            'padding-left': '88px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-025-ref', async () => {
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
          `Test passes if the blue and orange rectangles have the same width and the blue rectangle is in the upper-right corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '100px',
            'margin-bottom': '10px',
            'padding-left': '88px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            'margin-bottom': '10px',
            'padding-left': '88px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-027-ref', async () => {
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
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black rectangle.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            'padding-left': '96px',
            width: '96px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            'padding-left': '96px',
            width: '96px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('width-027', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black rectangle.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: '96px',
            position: 'absolute',
            right: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '96px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-029', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 96x96',
          src: 'assets/blue96x96.png',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: '96px',
            position: 'absolute',
            right: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '96px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('width-034', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is in the upper-right corner of an hollow black rectangle.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: '96px',
            position: 'absolute',
            right: 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('width-036-ref', async () => {
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
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '192px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            'margin-left': '48px',
            width: '96px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            'margin-left': '48px',
            width: '96px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-036', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 96x96',
          src: 'assets/blue96x96.png',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: '48px',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('width-037-ref', async () => {
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
          `Test passes if the blue and orange rectangles have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '50px',
            'margin-left': '44px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '50px',
            'margin-left': '44px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-039-ref', async () => {
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
          `Test passes if the blue and orange rectangles have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '100px',
            'margin-bottom': '10px',
            'padding-left': '44px',
            width: '200px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            height: '96px',
            'margin-bottom': '10px',
            'padding-left': '44px',
            width: '200px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('width-041-ref', async () => {
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
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black rectangle.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '288px',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            'padding-left': '48px',
            height: '96px',
            width: '96px',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            display: 'block',
            'padding-left': '48px',
            height: '96px',
            width: '96px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('width-041', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black rectangle.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: '48px',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('width-043', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 96x96',
          src: 'assets/blue96x96.png',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: '48px',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-048', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black rectangle.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            'margin-left': 'auto',
            'margin-right': 'auto',
            left: '48px',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('width-050', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 96x96',
          src: 'assets/blue96x96.png',
          style: {
            'margin-left': '24px',
            'margin-right': 'auto',
            left: '24px',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-055', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black rectangle.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            'margin-left': '24px',
            'margin-right': 'auto',
            left: '24px',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-057', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 96x96',
          src: 'assets/blue96x96.png',
          style: {
            left: '24px',
            'margin-left': '24px',
            'margin-right': 'auto',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-062', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black rectangle.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            left: '24px',
            'margin-left': '24px',
            'margin-right': 'auto',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-064', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 96x96',
          src: 'assets/blue96x96.png',
          style: {
            left: '24px',
            'margin-left': '24px',
            'margin-right': '48px',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-069', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black rectangle.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            left: '24px',
            'margin-left': '24px',
            'margin-right': '48px',
            position: 'absolute',
            right: '48px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-071', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '192px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 96x96',
          src: 'assets/blue96x96.png',
          style: {
            left: '48px',
            'margin-left': '48px',
            'margin-right': '24px',
            position: 'absolute',
            right: '24px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  xit('width-076', async () => {
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
        createText(
          `Test passes if the blue and orange squares have the same width and are `
        ),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in an hollow black rectangle.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '288px',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            left: '48px',
            'margin-left': '48px',
            'margin-right': '24px',
            position: 'absolute',
            right: '24px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            'margin-left': '48px',
            'margin-right': '48px',
            'margin-top': '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
});
