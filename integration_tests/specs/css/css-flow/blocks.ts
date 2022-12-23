/*auto generated*/
describe('blocks', () => {
  it('011', async () => {
    let p;
    let test;
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
      [createText(`Test passes if there is a short filled blue rectangle.`)]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          width: '30px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          class: 'test',
          style: {
            'margin-left': '0',
            'border-left': '20px solid',
            'padding-left': '0',
            width: 'auto',
            'padding-right': '0',
            'border-right': '20px solid',
            'margin-right': '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'margin-left': '0',
        'border-left': 'none',
        'padding-left': '0',
        width: '40px',
        'padding-right': '0',
        'border-right': 'none',
        'margin-right': '0',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(control);

    await snapshot();
  });
  it('012', async () => {
    let p;
    let test;
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
      [createText(`Test passes if there is a short filled blue rectangle.`)]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          width: '30px',
          background: 'blue',
          height: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          class: 'test',
          style: {
            'margin-left': '0',
            'border-left': 'none',
            'padding-left': '20px',
            width: 'auto',
            'padding-right': '20px',
            'border-right': 'none',
            'margin-right': '0',
            background: 'blue',
            height: '10px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'margin-left': '0',
        'border-left': 'none',
        'padding-left': '0',
        width: '40px',
        'padding-right': '0',
        'border-right': 'none',
        'margin-right': '0',
        background: 'blue',
        height: '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(control);

    await snapshot();
  });
  it('014', async () => {
    let p;
    let test;
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
      [createText(`Test passes if there is a short filled blue rectangle.`)]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          width: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          class: 'test',
          style: {
            'margin-left': '0',
            'border-left': '20px solid',
            'padding-left': '0',
            width: 'auto',
            'padding-right': '0',
            'border-right': '20px solid',
            'margin-right': '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'margin-left': '0',
        'border-left': 'none',
        'padding-left': '0',
        width: '50px',
        'padding-right': '0',
        'border-right': 'none',
        'margin-right': '0',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(control);

    await snapshot();
  });
  it('015', async () => {
    let p;
    let test;
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
      [createText(`Test passes if there is a short filled blue rectangle.`)]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          width: '50px',
          background: 'blue',
          height: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          class: 'test',
          style: {
            'margin-left': '0',
            'border-left': 'none',
            'padding-left': '20px',
            width: 'auto',
            'padding-right': '20px',
            'border-right': 'none',
            'margin-right': '0',
            background: 'blue',
            height: '10px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'margin-left': '0',
        'border-left': 'none',
        'padding-left': '0',
        width: '50px',
        'padding-right': '0',
        'border-right': 'none',
        'margin-right': '0',
        background: 'blue',
        height: '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(control);

    await snapshot();
  });

  // @TODO: Vertical padding not working for inline box.
  xit('018', async () => {
    let control;
    let test;
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '0',
          padding: '0',
          margin: '0',
          'line-height': '1',
          display: 'block',
          width: '100px',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              border: '0',
              padding: '0',
              margin: '0',
              'line-height': '1',
              display: 'inline',
              'white-space': 'nowrap',
              'padding-bottom': '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            (control = createElement(
              'span',
              {
                class: 'control',
                style: {
                  border: '0',
                  padding: '0',
                  margin: '0',
                  'line-height': '1',
                  display: 'inline',
                  'white-space': 'nowrap',
                  background: 'green',
                  color: 'white',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`Test passes if there is no red.`)]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  // @TODO: Vertical padding not working for inline box.
  xit('019', async () => {
    let control;
    let test;
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '0',
          padding: '0',
          margin: '0',
          'line-height': '1',
          display: 'block',
          width: '100px',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              border: '0',
              padding: '0',
              margin: '0',
              'line-height': '1',
              display: 'inline',
              'white-space': 'nowrap',
              'padding-top': '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            (control = createElement(
              'span',
              {
                class: 'control',
                style: {
                  border: '0',
                  padding: '0',
                  margin: '0',
                  'line-height': '1',
                  display: 'inline',
                  'white-space': 'nowrap',
                  background: 'green',
                  color: 'white',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`Test passes if there is no red.`)]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('020', async () => {
    let p;
    let inner;
    let outer;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green rectangle and `),
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
    outer = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'outer',
        style: {
          position: 'relative',
          width: '300px',
          height: '100px',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement(
          'div',
          {
            class: 'inner',
            style: {
              width: '200%',
              height: '200%',
              'font-size': '100px',
              color: 'green',
              'box-sizing': 'border-box',
            },
          },
          [createText(`XXX`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outer);

    await snapshot();
  });

  // @TODO: `font: '100px/1 Ahem'` shorthand parse error.
  xit('021', async () => {
    let p;
    let inner;
    let outer;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green rectangle and `),
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
    outer = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'outer',
        style: {
          position: 'absolute',
          width: '300px',
          height: '100px',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement(
          'div',
          {
            class: 'inner',
            style: {
              width: '200%',
              height: '200%',
              font: '100px/1 Ahem',
              color: 'green',
              'box-sizing': 'border-box',
            },
          },
          [createText(`XXX`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outer);

    await snapshot();
  });

  // @TODO: `font: '100px/1 Ahem'` shorthand parse error.
  xit('022', async () => {
    let p;
    let inner;
    let outer;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green rectangle and `),
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
    outer = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'outer',
        style: {
          position: 'static',
          width: '300px',
          height: '100px',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement(
          'div',
          {
            class: 'inner',
            style: {
              width: '200%',
              height: '200%',
              font: '100px/1 Ahem',
              color: 'green',
              'box-sizing': 'border-box',
            },
          },
          [createText(`XXX`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outer);

    await snapshot();
  });

  // @TODO: Input's default size should not contain border width.
  xit('026', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          margin: '0',
          border: '0',
          padding: '0',
          width: '50%',
          height: '300px',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a big filled green square and `),
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
          margin: '0',
          border: '0',
          padding: '0',
          height: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('p', {
          style: {
            margin: '0',
            border: '0',
            padding: '0',
            width: '50%',
            height: '300px',
            background: 'red',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    div_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          margin: '0',
          border: '0',
          padding: '0',
          height: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('input', {
          style: {
            margin: '0',
            border: '100px solid green',
            padding: '0',
            width: '50%',
            height: '300px',
            background: 'green',
            display: 'block',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('027', async () => {
    let p;
    let test;
    let control;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There must be a perfectly rectangular blue box below.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'test',
      style: {
        'border-left': '20px solid',
        'padding-left': '0',
        width: '30px',
        'padding-right': '0',
        'border-right': '20px solid',
        '-moz-box-sizing': 'border-box',
        'box-sizing': 'border-box',
      },
    });
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'border-left': 'none',
        'padding-left': '0',
        width: '40px',
        'padding-right': '0',
        'border-right': 'none',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(control);

    await snapshot();
  });
  it('028', async () => {
    let p;
    let test;
    let control;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There must be a perfectly rectangular blue box below.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'test',
      style: {
        'border-left': 'none',
        'padding-left': '20px',
        width: '30px',
        'padding-right': '20px',
        'border-right': 'none',
        '-moz-box-sizing': 'border-box',
        'box-sizing': 'border-box',
      },
    });
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'border-left': 'none',
        'padding-left': '0',
        width: '40px',
        'padding-right': '0',
        'border-right': 'none',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(control);

    await snapshot();
  });
});
