/*auto generated*/
describe('abspos-width', () => {
  it('002', async () => {
    let p;
    let inner;
    let inner_1;
    let a;
    let b;
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
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'absolute',
          top: '40px',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement('div', {
          class: 'inner',
          style: {
            background: 'red',
            height: '20px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'absolute',
          top: '80px',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner_1 = createElement('div', {
          class: 'inner',
          style: {
            background: 'red',
            height: '20px',
            width: '100%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(a);
    BODY.appendChild(b);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let inner;
    let inner_1;
    let a;
    let b;
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
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'absolute',
          top: '40px',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement('div', {
          class: 'inner',
          style: {
            background: 'red',
            height: '20px',
            width: 'auto',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'absolute',
          top: '80px',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner_1 = createElement('div', {
          class: 'inner',
          style: {
            background: 'red',
            height: '20px',
            width: '50%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(a);
    BODY.appendChild(b);

    await snapshot();
  });
  it('004', async () => {
    let p;
    let test;
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
    test = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'test',
        style: {
          width: '20px',
          height: '20px',
          padding: '20px',
          border: 'green solid 2px',
          background: 'red',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            top: '0',
            left: '0',
            width: '100%',
            height: '100%',
            background: 'green',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);

    await snapshot();
  });

  // @TODO: Impl setting longest words width as the minimum size of text.
  // https://github.com/openkraken/kraken/issues/401
  xit('005-ref', async () => {
    let p;
    let child;
    let parent;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `The blue rectangle should be well within the pink rectangle, but its text should overflow out of both rectangles.`
        ),
      ]
    );
    parent = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'parent',
        style: {
          border: 'fuchsia solid thin',
          height: '50px',
          padding: '10px',
          width: '100px',
        },
      },
      [
        (child = createElement(
          'div',
          {
            id: 'child',
            style: {
              border: 'aqua solid thin',
              padding: '10px',
              width: '30px',
            },
          },
          [createText(`overflowyflowyflowyflowyflowyflowyflowyflowy`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(parent);

    await snapshot();
  });

  // @TODO: Impl setting longest words width as the minimum size of text.
  // https://github.com/openkraken/kraken/issues/401
  xit('005', async () => {
    let p;
    let absolute;
    let relative;
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
          `The blue rectangle should be well within the pink rectangle, but its text should overflow out of both rectangles.`
        ),
      ]
    );
    relative = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'relative',
        style: {
          position: 'relative',
          border: 'fuchsia thin solid',
          padding: '10px',
          width: '100px',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (absolute = createElement(
          'div',
          {
            class: 'absolute',
            style: {
              position: 'absolute',
              border: 'aqua thin solid',
              padding: '10px',
              'max-width': '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(` overflowyflowyflowyflowyflowyflowyflowyflowy `)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(relative);

    await snapshot();
  });
  it('change-inline-container-001-ref', async () => {
    let abspos;
    let relpos;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'text-align': 'center',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (relpos = createElement(
          'span',
          {
            id: 'relpos',
            style: {
              position: 'relative',
              background: 'red',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`x
      `),
            (abspos = createElement('span', {
              id: 'abspos',
              style: {
                position: 'absolute',
                left: '0',
                top: '0',
                width: '50px',
                height: '50px',
                background: 'green',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
  it('change-inline-container-001', async () => {
    let abspos;
    let relpos;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'text-align': 'center',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (relpos = createElement(
          'span',
          {
            id: 'relpos',
            style: {
              position: 'relative',
              background: 'red',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`x
      `),
            (abspos = createElement('span', {
              id: 'abspos',
              style: {
                position: 'absolute',
                left: '0',
                top: '0',
                width: '50px',
                height: '50px',
                background: 'green',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    run();
    function run() {
      document.body.offsetTop;
      container.style.width = '100px';
    }

    await snapshot();
  });
});
