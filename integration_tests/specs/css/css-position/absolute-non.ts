/*auto generated*/
describe('absolute-non', () => {
  it('replaced-height-001', async () => {
    let p;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          margin: '0',
          padding: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes the a filled blue square touches the upper-left corner of the black box.`
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
          position: 'absolute',
          top: '96px',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            height: '96px',
            position: 'fixed',
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
  it('replaced-height-002-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: 'black solid medium',
          height: '200px',
          width: '200px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '100',
          height: '100',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-height-002', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: 'solid black',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              bottom: 'auto',
              color: 'blue',
              font: 'NaNpx NaNpx',
              height: 'auto',
              'margin-bottom': 'auto',
              'margin-top': 'auto',
              position: 'absolute',
              top: 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-height-003-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`vertically centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: 'black solid medium',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/1x1-white.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '96px',
            'vertical-align': 'top',
            width: '100%',
          },
        }),
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '96px',
            'vertical-align': 'top',
            width: '100%',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-height-003', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '48px',
            height: '96px',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            position: 'absolute',
            top: '48px',
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
  xit('replaced-height-004', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '48px',
            height: '96px',
            'margin-top': 'auto',
            'margin-bottom': '48px',
            position: 'absolute',
            top: '48px',
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
  xit('replaced-height-005', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '48px',
            height: '96px',
            'margin-bottom': 'auto',
            'margin-top': '48px',
            position: 'absolute',
            top: '48px',
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
  xit('replaced-height-006-ref', async () => {
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
          `Test passes if there is one and only one blue rectangle inside an hollow black square and if such black square does not have a vertical scrollbar.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: 'black solid 10px',
          height: '300px',
          width: '300px',
        },
      },
      [
        createElement('img', {
          src: 'assets/1x1-white.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '100px',
            'vertical-align': 'top',
            width: '100%',
          },
        }),
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '150px',
            'vertical-align': 'top',
            width: '100%',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-height-006', async () => {
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
          `Test passes if there is one and only one blue rectangle inside an hollow black square and if such black square does not have a vertical scrollbar.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '10px solid black',
          height: '300px',
          position: 'relative',
          width: '300px',
          overflow: 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            background: 'blue',
            height: '150px',
            'margin-bottom': '50px',
            'margin-top': '50px',
            position: 'absolute',
            top: '50px',
            width: '50%',
            bottom: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            background: 'blue',
            height: '150px',
            'margin-bottom': '50px',
            'margin-top': '50px',
            position: 'absolute',
            top: '50px',
            width: '50%',
            bottom: '0',
            left: '50%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-height-007-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if the orange and blue squares have the `),
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
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '100px',
            width: '100px',
          },
        }),
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '100px',
            width: '100px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);

    await snapshot();
  });
  xit('replaced-height-007', async () => {
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
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          color: 'orange',
          font: '100px/1 NaNpx',
          height: '300px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'blue',
              bottom: '200px',
              height: 'auto',
              'margin-bottom': 'auto',
              'margin-top': 'auto',
              position: 'absolute',
              top: 'auto',
              width: '100%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-height-008-ref', async () => {
    let p;
    let blue;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if a blue rectangle is below an orange square.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '96px',
            'vertical-align': 'top',
            width: '96px',
          },
        }),
        createElement('br', {
          style: {},
        }),
        (blue = createElement('img', {
          id: 'blue',
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '192px',
            'vertical-align': 'top',
            width: '96px',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-height-008', async () => {
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
      [createText(`Test passes if a blue rectangle is below an orange square.`)]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          background: 'blue',
          height: '288px',
          position: 'relative',
          width: '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'orange',
            bottom: 'auto',
            height: '96px',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            position: 'absolute',
            top: 'auto',
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
  it('replaced-height-009-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if the orange and blue squares have the `),
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
        style: {
          'margin-top': '41px',
        },
      },
      [
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '100px',
            width: '100px',
          },
        }),
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '100px',
            width: '100px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-height-009', async () => {
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
        createElement(
          'div',
          {
            style: {
              background: 'blue',
              bottom: 'auto',
              color: 'orange',
              font: '100px/1 NaNpx',
              height: 'auto',
              'margin-bottom': 'auto',
              'margin-top': 'auto',
              position: 'absolute',
              top: '25px',
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-height-010', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '96px',
            height: '96px',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            position: 'absolute',
            top: 'auto',
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
  xit('replaced-height-011', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '96px',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            position: 'absolute',
            top: '96px',
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
  xit('replaced-height-012', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            top: '96px',
            bottom: 'auto',
            height: '96px',
            'margin-top': 'auto',
            'margin-bottom': 'auto',
            background: 'blue',
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
  it('replaced-height-013', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
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
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          position: 'relative',
          width: '100px',
          height: '100px',
          background: 'red',
        },
      },
      [
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            position: 'absolute',
            top: '50%',
            bottom: '50%',
            width: '100px',
            height: '100px',
            margin: 'auto',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('replaced-max-height-001', async () => {
    let p;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          margin: '0',
          padding: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes a blue rectangle is in the upper-left corner of a hollow black square.`
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
          position: 'absolute',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            height: '96px',
            'max-height': '48px',
            position: 'fixed',
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
  xit('replaced-max-height-002-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a blue rectangle in the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '200px',
          width: '200px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '100',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {
            'padding-left': '100px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-max-height-002', async () => {
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
        createText(`Test passes if there is a blue rectangle in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: 'solid black',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: 'auto',
            font: '100px/1 NaNpx',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            'max-height': '50px',
            position: 'absolute',
            right: '0',
            top: 'auto',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-max-height-003-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`vertically centered`)]
        ),
        createText(` in an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: 'black solid medium',
          height: '288px',
          width: '288px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '288',
          height: '48',
          alt: 'Image download support must be enabled',
          style: {
            'padding-top': '120px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-max-height-003', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '48px',
            height: '96px',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            'max-height': '48px',
            position: 'absolute',
            top: '48px',
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
  xit('replaced-max-height-004', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '48px',
            height: '192px',
            'margin-bottom': '48px',
            'margin-top': 'auto',
            'max-height': '96px',
            position: 'absolute',
            top: '48px',
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
  xit('replaced-max-height-005', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '48px',
            height: '192px',
            'margin-bottom': 'auto',
            'margin-top': '48px',
            'max-height': '96px',
            position: 'absolute',
            top: '48px',
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
  xit('replaced-max-height-006', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '48px',
            height: '192px',
            'margin-bottom': '48px',
            'margin-top': '48px',
            'max-height': '96px',
            position: 'absolute',
            top: '48px',
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
  it('replaced-max-height-007-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if the blue and orange squares have the `),
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
        style: {
          'margin-top': '66px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '50',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          width: '50',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-max-height-007', async () => {
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
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          font: '100px/1 NaNpx',
          height: '400px',
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            background: 'orange',
            height: '50px',
            position: 'relative',
            top: '50px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            background: 'blue',
            bottom: '300px',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            'max-height': '50px',
            position: 'absolute',
            top: 'auto',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-max-height-008-ref', async () => {
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
          `Test passes if there is a small orange rectangle and a bigger blue rectangle.`
        ),
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
          src: 'assets/swatch-orange.png',
          width: '96',
          height: '48',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
        createElement('br', {
          style: {},
        }),
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '96',
          height: '240',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-max-height-008', async () => {
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
          `Test passes if there is a small orange rectangle and a bigger blue rectangle.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          background: 'blue',
          height: '288px',
          position: 'relative',
          width: '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'orange',
            bottom: 'auto',
            height: '96px',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            'max-height': '48px',
            position: 'absolute',
            top: 'auto',
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
  it('replaced-max-height-009-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if the orange and blue rectangles have the `),
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
        style: {
          'margin-top': '41px',
        },
      },
      [
        createElement('img', {
          src: 'assets/swatch-orange.png',
          width: '100',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '100',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-max-height-009', async () => {
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
        createText(`Test passes if the orange and blue rectangles have the `),
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
            background: 'blue',
            height: '50px',
            left: '100px',
            position: 'absolute',
            top: '25px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            background: 'orange',
            bottom: 'auto',
            font: '100px/1 NaNpx',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            'max-height': '50px',
            position: 'absolute',
            top: '25px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-max-height-010', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '96px',
            height: '192px',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            'max-height': '96px',
            position: 'absolute',
            top: 'auto',
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
  xit('replaced-max-height-011', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: '96px',
            height: 'auto',
            'margin-bottom': 'auto',
            'margin-top': 'auto',
            'max-height': '48px',
            position: 'absolute',
            top: '96px',
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
  xit('replaced-max-height-012', async () => {
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
        createText(`Test passes if a blue rectangle is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`vertically centered`)]
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
          border: 'solid black',
          height: '288px',
          position: 'relative',
          width: '288px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            bottom: 'auto',
            height: '192px',
            'margin-top': 'auto',
            'margin-bottom': 'auto',
            'max-height': '96px',
            position: 'absolute',
            top: '96px',
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
  xit('replaced-width-001', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: 'solid black',
          direction: 'ltr',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: 'auto',
              position: 'absolute',
              right: 'auto',
              width: 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-width-002-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '200px',
          'padding-left': '100px',
          width: '100px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '100',
          height: '100',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-width-002', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: 'solid black',
          direction: 'rtl',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: 'NaNpx NaNpx',
              left: 'auto',
              position: 'absolute',
              right: 'auto',
              width: 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-width-003-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black rectangle and if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '200px',
          'padding-left': '300px',
          width: '100px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '100',
          height: '100',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-width-003', async () => {
    let p;
    let containingblock;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black rectangle and if there is `),
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
    containingblock = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'containingblock',
        style: {
          border: '1px solid black',
          height: '200px',
          position: 'relative',
          width: '400px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: 'NaNpx NaNpx',
              left: '100px',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: '-200px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(containingblock);

    await snapshot();
  });
  xit('replaced-width-004', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          direction: 'ltr',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: 'NaNpx NaNpx',
              left: '100px',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: '100px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-005', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          direction: 'rtl',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: 'NaNpx NaNpx',
              left: '100px',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: '100px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-006', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          direction: 'ltr',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: '50px',
              'margin-left': '50px',
              'margin-right': 'auto',
              position: 'absolute',
              right: '100px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-007', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          direction: 'rtl',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: '100px',
              'margin-left': 'auto',
              'margin-right': '50px',
              position: 'absolute',
              right: '50px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-width-008-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black rectangle and if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '200px',
          width: '300px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '100',
          height: '100',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('replaced-width-008', async () => {
    let p;
    let containingblock;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black rectangle and if there is `),
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
    containingblock = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'containingblock',
        style: {
          border: '1px solid black',
          direction: 'ltr',
          height: '200px',
          position: 'relative',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: '100px',
              'margin-left': 'auto',
              'margin-right': '100px',
              position: 'absolute',
              right: '100px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(containingblock);

    await snapshot();
  });
  xit('replaced-width-009', async () => {
    let p;
    let containingblock;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of the black rectangle and there is `),
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
    containingblock = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'containingblock',
        style: {
          border: '1px solid black',
          direction: 'rtl',
          height: '200px',
          position: 'relative',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: '100px',
              'margin-left': '100px',
              'margin-right': 'auto',
              position: 'absolute',
              right: '100px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(containingblock);

    await snapshot();
  });
  xit('replaced-width-010', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: 'auto',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: '100px',
              width: 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-011', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          direction: 'ltr',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: 'auto',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: 'auto',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-012', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          direction: 'rtl',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: 'auto',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: 'auto',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-013', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: '100px/1 NaNpx',
              left: '100px',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: 'auto',
              width: 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-014', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-left corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: 'NaNpx NaNpx',
              left: 'auto',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: '100px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-width-015-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a filled blue square is `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`horizontally centered`)]
        ),
        createText(` inside an hollow black rectangle and if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '200px',
          'text-align': 'center',
          width: '300px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '100',
          height: '100',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('replaced-width-015', async () => {
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
        createText(`Test passes if a filled blue square is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` inside an hollow black rectangle and if there is `),
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
          border: '1px solid black',
          height: '200px',
          position: 'relative',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            left: '100px',
            height: '100px',
            'margin-left': 'auto',
            'margin-right': 'auto',
            position: 'absolute',
            right: '100px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-016', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square and if there is `),
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
          border: '1px solid black',
          height: '200px',
          position: 'relative',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'red',
              color: 'blue',
              font: 'NaNpx NaNpx',
              left: '100px',
              'margin-left': 'auto',
              'margin-right': 'auto',
              position: 'absolute',
              right: 'auto',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('replaced-width-017-ref', async () => {
    let p;
    let green45X120;
    let green45X120_1;
    let blackStripe;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Below there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the right. There should be no red in this page.`
        ),
      ]
    );
    green45X120 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'green-45x120',
      style: {
        'background-color': 'green',
        height: '45px',
        width: '120px',
      },
    });
    blackStripe = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'black-stripe',
      style: {
        'background-color': 'black',
        height: '30px',
        width: '240px',
      },
    });
    green45X120_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'green-45x120',
      style: {
        'background-color': 'green',
        height: '45px',
        width: '120px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(green45X120);
    BODY.appendChild(green45X120_1);
    BODY.appendChild(blackStripe);

    await snapshot();
  });
  xit('replaced-width-017', async () => {
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
          `Below there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the right. There should be no red in this page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'red',
          font: '30px/4 NaNpx',
          left: 'auto',
          position: 'absolute',
          right: 'auto',
          width: 'auto',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'background-color': 'green',
              display: 'inline-block',
              'max-width': '40px',
            },
          },
          [createText(`12345678`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('replaced-width-018', async () => {
    let p;
    let innerInlineBlock;
    let outerAbsPos;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Below there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the right. There should be no red in this page.`
        ),
      ]
    );
    outerAbsPos = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'outer-abs-pos',
        style: {
          'background-color': 'red',
          font: '30px/4 NaNpx',
          left: 'auto',
          position: 'absolute',
          right: 'auto',
          width: 'auto',
        },
      },
      [
        (innerInlineBlock = createElement(
          'div',
          {
            id: 'inner-inline-block',
            style: {
              'background-color': 'green',
              display: 'inline-block',
              'max-width': '40px',
            },
          },
          [createText(`12345678`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outerAbsPos);

    await snapshot();
  });
  xit('replaced-width-019', async () => {
    let p;
    let innerFloated;
    let outerAbsPos;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Below there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the right. There should be no red in this page.`
        ),
      ]
    );
    outerAbsPos = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'outer-abs-pos',
        style: {
          'background-color': 'red',
          font: '30px/4 NaNpx',
          left: 'auto',
          position: 'absolute',
          right: 'auto',
          width: 'auto',
        },
      },
      [
        (innerFloated = createElement(
          'div',
          {
            id: 'inner-floated',
            style: {
              'background-color': 'green',
              float: 'left',
              'max-width': '40px',
            },
          },
          [createText(`12345678`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outerAbsPos);

    await snapshot();
  });
  xit('replaced-width-020', async () => {
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
          `Below there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the right. There should be no red in this page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'red',
          font: '30px/4 NaNpx',
          left: 'auto',
          position: 'absolute',
          right: 'auto',
          width: 'auto',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'background-color': 'green',
              float: 'left',
              'max-width': '40px',
            },
          },
          [createText(`12345678`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('replaced-width-021-ref', async () => {
    let p;
    let green45X120;
    let green45X120_1;
    let blackStripe;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Below, on the right edge of the page, there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the left. There should be no red in this page.`
        ),
      ]
    );
    green45X120 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'green-45x120',
      style: {
        'background-color': 'green',
        height: '45px',
        'margin-left': 'auto',
        width: '120px',
      },
    });
    blackStripe = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'black-stripe',
      style: {
        'background-color': 'black',
        height: '30px',
        'margin-left': 'auto',
        width: '240px',
      },
    });
    green45X120_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'green-45x120',
      style: {
        'background-color': 'green',
        height: '45px',
        'margin-left': 'auto',
        width: '120px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(green45X120);
    BODY.appendChild(green45X120_1);
    BODY.appendChild(blackStripe);

    await snapshot();
  });
  xit('replaced-width-021', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createText(
          `Below, on the right edge of the page, there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the left. There should be no red in this page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'red',
          font: '30px/4 NaNpx',
          left: 'auto',
          position: 'absolute',
          right: 'auto',
          width: 'auto',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'background-color': 'green',
              display: 'inline-block',
              'max-width': '40px',
            },
          },
          [createText(`12345678`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('replaced-width-022', async () => {
    let p;
    let innerInlineBlock;
    let outerAbsPos;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createText(
          `Below, on the right edge of the page, there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the left. There should be no red in this page.`
        ),
      ]
    );
    outerAbsPos = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'outer-abs-pos',
        style: {
          'background-color': 'red',
          font: '30px/4 NaNpx',
          left: 'auto',
          position: 'absolute',
          right: 'auto',
          width: 'auto',
        },
      },
      [
        (innerInlineBlock = createElement(
          'div',
          {
            id: 'inner-inline-block',
            style: {
              'background-color': 'green',
              display: 'inline-block',
              'max-width': '40px',
            },
          },
          [createText(`12345678`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outerAbsPos);

    await snapshot();
  });
  xit('replaced-width-023', async () => {
    let p;
    let innerFloated;
    let outerAbsPos;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createText(
          `Below, on the right edge of the page, there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the left. There should be no red in this page.`
        ),
      ]
    );
    outerAbsPos = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'outer-abs-pos',
        style: {
          'background-color': 'red',
          font: '30px/4 NaNpx',
          left: 'auto',
          position: 'absolute',
          right: 'auto',
          width: 'auto',
        },
      },
      [
        (innerFloated = createElement(
          'div',
          {
            id: 'inner-floated',
            style: {
              'background-color': 'green',
              float: 'left',
              'max-width': '40px',
            },
          },
          [createText(`12345678`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outerAbsPos);

    await snapshot();
  });
  xit('replaced-width-024', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createText(
          `Below, on the right edge of the page, there should be a green square. In the middle of such green square, a black horizontal stripe should be traversing it and protruding out of it toward the left. There should be no red in this page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'red',
          font: '30px/4 NaNpx',
          left: 'auto',
          position: 'absolute',
          right: 'auto',
          width: 'auto',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'background-color': 'green',
              float: 'left',
              'max-width': '40px',
            },
          },
          [createText(`12345678`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('replaced-width-025-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a green square `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in the page and if there is `),
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
        height: '100px',
        margin: '0px auto',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('replaced-width-025', async () => {
    let p;
    let absPosOverlappingGreen;
    let overlappedRed;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a green square `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`horizontally centered`)]
        ),
        createText(` in the page and if there is `),
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
    absPosOverlappingGreen = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'abs-pos-overlapping-green',
      style: {
        'background-color': 'green',
        height: '100px',
        left: '8px',
        'margin-left': 'auto',
        'margin-right': 'auto',
        'max-width': '100px',
        position: 'absolute',
        right: '8px',
        width: 'auto',
      },
    });
    overlappedRed = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'overlapped-red',
        style: {
          'background-color': 'red',
          color: 'yellow',
          'font-size': '20px',
          height: '100px',
          'margin-left': 'auto',
          'margin-right': 'auto',
          width: '100px',
        },
      },
      [createText(`FAIL`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(absPosOverlappingGreen);
    BODY.appendChild(overlappedRed);

    await snapshot();
  });
  xit('replaced-width-026-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a green square on the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`right side`)]
        ),
        createText(` of this page and if there is `),
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
        height: '100px',
        'margin-left': 'auto',
        'margin-right': '0px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('replaced-width-026', async () => {
    let p;
    let absPosOverlappingGreen;
    let overlappedRed;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a green square on the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`right side`)]
        ),
        createText(` of this page and if there is `),
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
    absPosOverlappingGreen = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'abs-pos-overlapping-green',
      style: {
        'background-color': 'green',
        height: '100px',
        left: '8px',
        'margin-left': 'auto',
        'margin-right': '0px',
        'max-width': '100px',
        position: 'absolute',
        right: '8px',
        width: 'auto',
      },
    });
    overlappedRed = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'overlapped-red',
        style: {
          'background-color': 'red',
          color: 'yellow',
          'font-size': '20px',
          height: '100px',
          'margin-left': 'auto',
          'margin-right': '0px',
          width: '100px',
        },
      },
      [createText(`FAIL`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(absPosOverlappingGreen);
    BODY.appendChild(overlappedRed);

    await snapshot();
  });
  it('replaced-width-027', async () => {
    let p;
    let referenceRedOverlapped;
    let testGreenOverlapping;
    let relPosContainer;
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
    relPosContainer = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'rel-pos-container',
        style: {
          'background-color': 'green',
          height: '100px',
          position: 'relative',
          width: '100px',
        },
      },
      [
        (referenceRedOverlapped = createElement('div', {
          id: 'reference-red-overlapped',
          style: {
            position: 'absolute',
            'background-color': 'red',
            height: '33px',
            left: '33px',
            top: '33px',
            width: '33px',
          },
        })),
        (testGreenOverlapping = createElement('div', {
          id: 'test-green-overlapping',
          style: {
            position: 'absolute',
            'background-color': 'green',
            bottom: '0',
            height: 'auto',
            left: '0',
            margin: 'auto',
            'max-height': '34px',
            'max-width': '34px',
            right: '0',
            top: '0',
            width: 'auto',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(relPosContainer);

    await snapshot();
  });
  xit('replaced-width-028', async () => {
    let p;
    let p_1;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `PREREQUISITE: User agent needs to support scrollbars as the scrolling mechanism. If it does not, then this test does not apply to such user agent.`
        ),
      ]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if there is a filled green rectangle with inactive scrollbars and `
        ),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'red',
          position: 'absolute',
          height: '100px',
          overflow: 'scroll',
        },
      },
      [
        createElement('img', {
          src: 'assets/green-rectangle-50wideBy10tall.png',
          alt: 'Image download support must be enabled',
          style: {
            height: '100%',
            'vertical-align': 'bottom',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
});
