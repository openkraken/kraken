/*auto generated*/
describe('right-offset', () => {
  it('001-ref', async () => {
    let p;
    let inlineBlock;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if there is a blue square with its top-left corner missing.`
        ),
      ]
    );
    inlineBlock = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'inline-block',
        style: {
          display: 'inline-block',
        },
      },
      [
        createElement(
          'div',
          {
            style: {},
          },
          [
            createElement('img', {
              src: 'assets/1x1-white.png',
              width: '50',
              height: '50',
              alt: 'Image download support must be enabled',
              style: {
                'vertical-align': 'top',
              },
            }),
            createElement('img', {
              src: 'assets/blue15x15.png',
              width: '50',
              height: '50',
              alt: 'Image download support must be enabled',
              style: {
                'vertical-align': 'top',
              },
            }),
          ]
        ),
        createElement(
          'div',
          {
            style: {},
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
              src: 'assets/blue15x15.png',
              width: '50',
              height: '50',
              alt: 'Image download support must be enabled',
              style: {
                'vertical-align': 'top',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(inlineBlock);

    await snapshot(0.1);
  });
  it('001', async () => {
    let p;
    let div1;
    let div2;
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
          `Test passes if there is a blue square with its top-left corner missing.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          height: '100px',
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement('div', {
          id: 'div1',
          style: {
            height: '100px',
            position: 'relative',
            width: '100px',
            background: 'blue',
            'box-sizing': 'border-box',
          },
        })),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '50px',
            position: 'absolute',
            width: '50px',
            background: 'white',
            right: '50px',
            top: '0',
            'box-sizing': 'border-box',
          },
        })),
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
        createText(
          `Test passes if there is a blue square with its top-right corner missing.`
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
          height: '100px',
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'white',
            height: '50px',
            position: 'relative',
            right: '-50px',
            width: '50px',
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
    let div1;
    let div2;
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
          `Test passes if there is a blue square with its top-left corner missing.`
        ),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'container',
        style: {
          height: '100px',
          'padding-right': '25px',
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement('div', {
          id: 'div1',
          style: {
            background: 'white',
            height: '50px',
            position: 'absolute',
            right: '75px',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            background: 'blue',
            height: '100px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('004', async () => {
    let p;
    let relPosOverlappingGreen;
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createElement('img', {
          src: 'assets/100x100-red.png',
          width: '100',
          height: '100',
          alt: 'Image download support must be enabled',
          style: {},
        }),
        (relPosOverlappingGreen = createElement('img', {
          id: 'rel-pos-overlapping-green',
          src: 'assets/swatch-green.png',
          width: '100',
          height: '100',
          alt: 'Image download support must be enabled',
          style: {
            position: 'relative',
            right: '100px',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.5);
  });
  it('percentage-001-ref', async () => {
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
          `Test passes if a blue square is in the top-left corner of an hollow black rectangle.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          height: '200px',
          width: '100px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '50',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('percentage-001', async () => {
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
          `Test passes if a blue square is in the top-left corner of an hollow black rectangle.`
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
          height: '200px',
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            height: '50px',
            'margin-left': '50px',
            position: 'absolute',
            right: '50%',
            width: '50px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
});
