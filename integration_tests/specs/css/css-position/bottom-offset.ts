/*auto generated*/
describe('bottom-offset', () => {
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
            bottom: '0',
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
          position: 'relative',
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
            bottom: '-48px',
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
          'padding-bottom': '48px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            background: 'white',
            height: '48px',
            position: 'absolute',
            bottom: '48px',
            width: '48px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
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
    BODY.appendChild(div1);

    await snapshot();
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
          `Test passes if there is a filled green box that is not in any of the corners of an hollow black rectangle and if there is `
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
          height: '150px',
          'padding-top': '50px',
          width: '100px',
        },
      },
      [
        createElement('img', {
          src: 'assets/1x1-green.png',
          width: '50',
          height: '50',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.5);
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
          `Test passes if there is a filled green box that is not in any of the corners of an hollow black rectangle and if there is `
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
            top: '50px',
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
            bottom: '50%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
});
