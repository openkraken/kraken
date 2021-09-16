/*auto generated*/
describe('top-offset', () => {
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
          `Test passes if there is a blue square with its bottom-left corner missing.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          height: '96px',
          position: 'relative',
          width: '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement('div', {
          id: 'div1',
          style: {
            height: '96px',
            position: 'relative',
            width: '96px',
            background: 'blue',
            'box-sizing': 'border-box',
          },
        })),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '48px',
            position: 'absolute',
            width: '48px',
            background: 'white',
            top: '48px',
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
          `Test passes if there is a blue square with its bottom-left corner missing.`
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
          height: '96px',
          width: '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'white',
            height: '48px',
            position: 'relative',
            top: '48px',
            width: '48px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('003-ref', async () => {
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
          `Test passes if there is a blue square with its bottom-left corner missing.`
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
          'padding-top': '24px',
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
              width: '48',
              height: '48',
              alt: 'Image download support must be enabled',
              style: {
                'vertical-align': 'top',
              },
            }),
            createElement('img', {
              src: 'assets/blue15x15.png',
              width: '48',
              height: '48',
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
              src: 'assets/1x1-white.png',
              width: '48',
              height: '48',
              alt: 'Image download support must be enabled',
              style: {
                'vertical-align': 'top',
              },
            }),
            createElement('img', {
              src: 'assets/blue15x15.png',
              width: '48',
              height: '48',
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
          `Test passes if there is a blue square with its bottom-left corner missing.`
        ),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'container',
        style: {
          height: '96px',
          'padding-top': '24px',
          position: 'relative',
          width: '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement('div', {
          id: 'div1',
          style: {
            background: 'white',
            height: '48px',
            position: 'absolute',
            top: '72px',
            width: '48px',
            'box-sizing': 'border-box',
          },
        })),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            background: 'blue',
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
          `Test passes if a filled green square is not in any of the corners of the hollow black rectangle and there is `
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
          border: '1px solid black',
          height: '200px',
          width: '100px',
        },
      },
      [
        createElement('img', {
          src: 'assets/1x1-green.png',
          width: '50',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {
            'padding-top': '100px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('percentage-001', async () => {
    let p;
    let reference;
    let test;
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
          `Test passes if a filled green square is not in any of the corners of the hollow black rectangle and there is `
        ),
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
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (reference = createElement('div', {
          id: 'reference',
          style: {
            height: '50px',
            position: 'absolute',
            width: '50px',
            background: 'red',
            bottom: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (test = createElement('div', {
          id: 'test',
          style: {
            height: '50px',
            position: 'absolute',
            width: '50px',
            background: 'green',
            top: '50%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

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
                left: '0px',
                top: 'inherit',
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
