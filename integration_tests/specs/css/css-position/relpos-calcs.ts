/*auto generated*/
describe('relpos-calcs', () => {
  it('001-ref', async () => {
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
        height: '120px',
        width: '120px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('001', async () => {
    let p;
    let inner;
    let outer;
    let container;
    let control;
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
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          height: '120px',
          width: '120px',
          'margin-top': '-60px',
          'box-sizing': 'border-box',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            style: {
              height: '120px',
              width: '120px',
              background: 'red',
              position: 'relative',
              bottom: '-50%',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement('div', {
              class: 'inner',
              style: {
                height: '120px',
                width: '120px',
                background: 'green',
                position: 'relative',
                top: 'inherit',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        height: '120px',
        width: '120px',
        background: 'red',
        'margin-top': '-60px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(control);

    await snapshot();
  });
  xit('002', async () => {
    let p;
    let inner;
    let outer;
    let container;
    let control;
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
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          height: '120px',
          width: '120px',
          'margin-top': '-60px',
          'box-sizing': 'border-box',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            style: {
              height: '120px',
              width: '120px',
              background: 'red',
              position: 'relative',
              top: '50%',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement('div', {
              class: 'inner',
              style: {
                height: '120px',
                width: '120px',
                background: 'green',
                position: 'relative',
                bottom: 'inherit',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        height: '120px',
        width: '120px',
        background: 'red',
        'margin-top': '-60px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(control);

    await snapshot();
  });
  xit('003', async () => {
    let p;
    let control;
    let inner;
    let outer;
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
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        height: '120px',
        width: '120px',
        background: 'red',
        'margin-bottom': '-120px',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          height: '120px',
          width: '120px',
          'margin-left': '-60px',
          'box-sizing': 'border-box',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            style: {
              height: '120px',
              width: '120px',
              background: 'red',
              position: 'relative',
              right: '-50%',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement('div', {
              class: 'inner',
              style: {
                height: '120px',
                width: '120px',
                background: 'green',
                position: 'relative',
                left: 'inherit',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(control);
    BODY.appendChild(container);

    await snapshot();
  });
  xit('004', async () => {
    let p;
    let control;
    let inner;
    let outer;
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
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        height: '120px',
        width: '120px',
        'margin-right': 'auto',
        direction: 'ltr',
        background: 'red',
        'margin-bottom': '-120px',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        dir: 'rtl',
        style: {
          height: '120px',
          width: '120px',
          'margin-right': 'auto',
          direction: 'rtl',
          'margin-left': '-60px',
          'box-sizing': 'border-box',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            dir: 'ltr',
            style: {
              height: '120px',
              width: '120px',
              'margin-right': 'auto',
              direction: 'ltr',
              background: 'red',
              position: 'relative',
              left: '50%',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement('div', {
              class: 'inner',
              style: {
                height: '120px',
                width: '120px',
                'margin-right': 'auto',
                direction: 'ltr',
                background: 'green',
                position: 'relative',
                right: 'inherit',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(control);
    BODY.appendChild(container);

    await snapshot();
  });
  xit('005', async () => {
    let p;
    let control;
    let inner;
    let outer;
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
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        height: '120px',
        width: '120px',
        direction: 'rtl',
        'margin-right': 'auto',
        background: 'red',
        'margin-bottom': '-120px',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        dir: 'ltr',
        style: {
          height: '120px',
          width: '80px',
          direction: 'ltr',
          'margin-right': 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            dir: 'rtl',
            style: {
              height: '120px',
              width: '80px',
              direction: 'rtl',
              'margin-right': 'auto',
              background: 'green',
              position: 'relative',
              left: '50%',
              right: '50%',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement('div', {
              class: 'inner',
              style: {
                height: '120px',
                width: '80px',
                direction: 'rtl',
                'margin-right': 'auto',
                background: 'green',
                position: 'relative',
                right: 'inherit',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(control);
    BODY.appendChild(container);

    await snapshot();
  });
  xit('006', async () => {
    let p;
    let control;
    let inner;
    let outer;
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
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        height: '120px',
        width: '120px',
        direction: 'rtl',
        background: 'red',
        'margin-bottom': '-120px',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        dir: 'rtl',
        style: {
          height: '120px',
          width: '80px',
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            style: {
              height: '120px',
              width: '80px',
              direction: 'rtl',
              background: 'green',
              position: 'relative',
              left: '-50%',
              right: '-50%',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement('div', {
              class: 'inner',
              style: {
                height: '120px',
                width: '80px',
                direction: 'rtl',
                background: 'green',
                position: 'relative',
                left: 'inherit',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(control);
    BODY.appendChild(container);

    await snapshot();

    await snapshot();

    await snapshot();
  });
  xit('007', async () => {
    let p;
    let inner;
    let outer;
    let container;
    let control;
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
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          height: '80px',
          width: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            style: {
              height: '80px',
              width: '120px',
              background: 'green',
              position: 'relative',
              top: '50%',
              bottom: '50%',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement('div', {
              class: 'inner',
              style: {
                height: '80px',
                width: '120px',
                background: 'green',
                position: 'relative',
                bottom: 'inherit',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        height: '120px',
        width: '120px',
        background: 'red',
        'margin-top': '-80px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(control);

    await snapshot();
  });
});
