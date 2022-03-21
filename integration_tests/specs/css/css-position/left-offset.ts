/*auto generated*/
describe('left-offset', () => {
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
          `Test passes if there is a blue square with its top-right corner missing.`
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
              src: 'assets/blue15x15.png',
              width: '50',
              height: '50',
              alt: 'Image download support must be enabled',
              style: {
                'vertical-align': 'top',
              },
            }),
            createElement('img', {
              src: 'assets/1x1-white.png',
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
            position: 'absolute',
            left: '50px',
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
            left: '50px',
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
  xit('003-ref', async () => {
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
          `Test passes if a filled black square is in the upper-right corner of an hollow blue rectangle.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid blue',
          direction: 'rtl',
          height: '96px',
          width: '120px',
        },
      },
      [
        createElement('img', {
          src: 'assets/black15x15.png',
          width: '48',
          height: '48',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

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
          `Test passes if a filled black square is in the upper-right corner of an hollow blue rectangle.`
        ),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'container',
        style: {
          border: '1px solid blue',
          height: '96px',
          'padding-left': '24px',
          position: 'relative',
          width: '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement('div', {
          id: 'div1',
          style: {
            background: 'black',
            height: '48px',
            position: 'absolute',
            left: '72px',
            width: '48px',
            'box-sizing': 'border-box',
          },
        })),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  xit('percentage-001-ref', async () => {
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
          `Test passes if a blue square is in the top-right corner of an hollow black rectangle.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid black',
          direction: 'rtl',
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

    await snapshot();
  });
  it('percentage-001', async () => {
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
          `Test passes if a blue square is in the top-right corner of an hollow black rectangle.`
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
          height: '150px',
          padding: '25px',
          position: 'relative',
          width: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            height: '50px',
            left: '50%',
            position: 'absolute',
            top: '0',
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
  it('percentage-002-ref', async () => {
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
        left: '300px',
        height: '100px',
        position: 'relative',
        top: '100px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('percentage-002', async () => {
    let p;
    let redAbsPosOverlapped;
    let greenChildAbsPosInheritOverlapping;
    let parentAbsPos;
    let grandParentAbsPos;
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
    grandParentAbsPos = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'grand-parent-abs-pos',
        style: {
          position: 'absolute',
          height: '400px',
          width: '600px',
        },
      },
      [
        (redAbsPosOverlapped = createElement(
          'div',
          {
            id: 'red-abs-pos-overlapped',
            style: {
              position: 'absolute',
              'background-color': 'red',
              color: 'white',
              height: '100px',
              left: '300px',
              top: '100px',
              width: '100px',
            },
          },
          [createText(`test FAILED`)]
        )),
        (parentAbsPos = createElement(
          'div',
          {
            id: 'parent-abs-pos',
            style: {
              position: 'absolute',
              height: '0px',
              left: '50%',
              top: '25%',
              width: '0px',
            },
          },
          [
            (greenChildAbsPosInheritOverlapping = createElement('div', {
              id: 'green-child-abs-pos-inherit-overlapping',
              style: {
                position: 'absolute',
                'background-color': 'green',
                left: 'inherit',
                top: '0px',
                height: '100px',
                width: '100px',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(grandParentAbsPos);

    await snapshot();
  });
});
