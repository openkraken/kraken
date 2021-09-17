/*auto generated*/
describe('position-relative', () => {
  it('001-ref', async () => {
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
          `Test passes if the letters below are all on the same line and they are in alphabetical order.`
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
      [createText(`a b c d`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('001', async () => {
    let p;
    let span1;
    let span2;
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
          `Test passes if the letters below are all on the same line and they are in alphabetical order.`
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
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [createText(`a`)]
        )),
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`b`)]
        ),
        (span2 = createElement(
          'span',
          {
            id: 'span2',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [createText(`c`)]
        )),
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`d`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('002', async () => {
    let p;
    let div1;
    let span1;
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
          `Test passes if the letter "a" is below the blue line and the letter "b" is above the blue line.`
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
        (div1 = createElement('div', {
          id: 'div1',
          style: {
            background: 'blue',
            height: '2px',
            left: '0',
            position: 'relative',
            top: '24px',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              position: 'relative',
              top: '25px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`a`)]
        )),
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`b`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('003-ref', async () => {
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
          `Test passes if "Filler Text" is aligned to the left side of the box.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '3px solid black',
          width: '480px',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('003', async () => {
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
          `Test passes if "Filler Text" is aligned to the left side of the box.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '1px solid 3px',
          width: '480px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              position: 'relative',
              left: 'auto',
              right: 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('004-ref', async () => {
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
          `Test passes if 3 filled squares have the same size and if the yellow square is on the right-hand side of the orange square.`
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
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-yellow.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    div_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createElement('img', {
          src: 'assets/swatch-white.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-blue.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.5);
  });
  it('004', async () => {
    let p;
    let div1;
    let div2;
    let div3;
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
          `Test passes if 3 filled squares have the same size and if the yellow square is on the right-hand side of the orange square.`
        ),
      ]
    );
    div1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div1',
      style: {
        height: '96px',
        width: '96px',
        background: 'orange',
        position: 'absolute',
        'box-sizing': 'border-box',
      },
    });
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        height: '96px',
        width: '96px',
        background: 'yellow',
        left: '96px',
        position: 'relative',
        'box-sizing': 'border-box',
      },
    });
    div3 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div3',
      style: {
        height: '96px',
        width: '96px',
        background: 'blue',
        position: 'relative',
        right: '-96px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);
    BODY.appendChild(div3);

    await snapshot();
  });
  it('005-ref', async () => {
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
          `Test passes if a blue square is on the right-hand side of an orange square.`
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
          src: 'assets/swatch-orange.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '96',
          height: '96',
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
  it('005', async () => {
    let p;
    let div1;
    let div2;
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
          `Test passes if a blue square is on the right-hand side of an orange square.`
        ),
      ]
    );
    div1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div1',
      style: {
        height: '96px',
        width: '96px',
        background: 'orange',
        position: 'absolute',
        'box-sizing': 'border-box',
      },
    });
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        height: '96px',
        width: '96px',
        background: 'blue',
        left: '96px',
        position: 'relative',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
  it('006', async () => {
    let p;
    let span1;
    let span2;
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
          `Test passes if a blue square is on the right-hand side of an orange square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement('span', {
          id: 'span1',
          style: {
            display: 'block',
            height: '96px',
            width: '96px',
            background: 'orange',
            'box-sizing': 'border-box',
          },
        })),
        (span2 = createElement('span', {
          id: 'span2',
          style: {
            display: 'block',
            height: '96px',
            width: '96px',
            background: 'blue',
            position: 'relative',
            right: '-96px',
            top: '-96px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('007', async () => {
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
          `Test passes if a blue square is on the right-hand side of an orange square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '96px',
          width: '96px',
          'margin-left': '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '96px',
            width: '96px',
            background: 'blue',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            height: '96px',
            width: '96px',
            background: 'orange',
            position: 'relative',
            left: 'auto',
            right: '96px',
            top: '-96px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('008', async () => {
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
          `Test passes if a blue square is on the right-hand side of an orange square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '96px',
          width: '96px',
          'margin-left': '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '96px',
            width: '96px',
            background: 'orange',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            height: '96px',
            width: '96px',
            background: 'blue',
            position: 'relative',
            left: '96px',
            right: 'auto',
            top: '-96px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('009', async () => {
    let p;
    let div1;
    let div2;
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
          `Test passes if a blue square is on the right-hand side of an orange square.`
        ),
      ]
    );
    div1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div1',
      style: {
        height: '96px',
        width: '96px',
        background: 'orange',
        'box-sizing': 'border-box',
      },
    });
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        height: '96px',
        width: '96px',
        background: 'blue',
        left: '96px',
        position: 'relative',
        right: '96px',
        top: '-96px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
  it('010', async () => {
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
          `Test passes if a blue square is on the right-hand side of an orange square.`
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
          direction: 'rtl',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'orange',
            height: '96px',
            left: '96px',
            position: 'relative',
            right: '96px',
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
  it('013', async () => {
    let p;
    let div1;
    let div2;
    let div3;
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
    div1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div1',
      style: {
        height: '100px',
        position: 'relative',
        width: '100px',
        'background-color': 'red',
        'box-sizing': 'border-box',
      },
    });
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        height: '100px',
        position: 'relative',
        width: '100px',
        'background-color': 'red',
        bottom: '100px',
        top: 'auto',
        'box-sizing': 'border-box',
      },
    });
    div3 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div3',
      style: {
        height: '100px',
        position: 'relative',
        width: '100px',
        'background-color': 'green',
        bottom: '0px',
        top: '-200px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);
    BODY.appendChild(div3);

    await snapshot();
  });
  it('014-ref', async () => {
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
          `Test passes if a blue square is directly below an orange square.`
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
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    div_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createElement('img', {
          src: 'assets/swatch-blue.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('014', async () => {
    let p;
    let div1;
    let div2;
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
          `Test passes if a blue square is directly below an orange square.`
        ),
      ]
    );
    div1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div1',
      style: {
        height: '96px',
        width: '96px',
        background: 'orange',
        position: 'absolute',
        'box-sizing': 'border-box',
      },
    });
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        height: '96px',
        width: '96px',
        background: 'blue',
        position: 'relative',
        top: '96px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
  it('015', async () => {
    let p;
    let div1;
    let div2;
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
          `Test passes if a blue square is directly below an orange square.`
        ),
      ]
    );
    div1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div1',
      style: {
        height: '96px',
        width: '96px',
        background: 'blue',
        position: 'relative',
        top: '96px',
        'box-sizing': 'border-box',
      },
    });
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        height: '96px',
        width: '96px',
        background: 'orange',
        bottom: '96px',
        position: 'relative',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
  it('016-ref', async () => {
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'padding-top': '98px',
        },
      },
      [
        createElement('img', {
          src: 'assets/swatch-green.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  // Some position relation case not works right
  // restrict to flutter's renderiing pipe
  xit('016', async () => {
    let p;
    let div0;
    let div1;
    let div3;
    let div2;
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
    div0 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div0',
      style: {
        height: '0',
        width: '96px',
        border: '1px solid transparent',
        'box-sizing': 'border-box',
      },
    });
    div1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div1',
      style: {
        height: '96px',
        width: '96px',
        position: 'absolute',
        background: 'red',
        'margin-top': '96px',
        'box-sizing': 'border-box',
      },
    });
    div2 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div2',
        style: {
          height: '96px',
          width: '96px',
          bottom: '-96px',
          position: 'relative',
          top: 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            height: '96px',
            width: '96px',
            background: 'green',
            position: 'relative',
            top: 'inherit',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div0);
    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
  it('017', async () => {
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
          `Test passes if a blue square is directly below an orange square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '192px',
          width: '96px',
          background: 'blue',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            height: '96px',
            width: '96px',
            background: 'orange',
            position: 'relative',
            top: 'auto',
            bottom: 'auto',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('018-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is only one filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'black',
        height: '96px',
        'margin-top': '112px',
        width: '96px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('019', async () => {
    let p;
    let div1;
    let div2;
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
          `Test passes if a blue square is directly below an orange square.`
        ),
      ]
    );
    div1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div1',
      style: {
        height: '96px',
        width: '96px',
        background: 'orange',
        position: 'absolute',
        'box-sizing': 'border-box',
      },
    });
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        height: '96px',
        width: '96px',
        background: 'blue',
        bottom: '288px',
        position: 'relative',
        top: '96px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
  xit('020', async () => {
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
          `Test passes if, after scrolling down, all four edges of a blue square are visible.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '144px',
          position: 'relative',
          overflow: 'auto',
          width: '144px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            border: '5px blue solid',
            height: '96px',
            position: 'relative',
            top: '96px',
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
  xit('021', async () => {
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
          `Test passes if, after scrolling down, all four edges of a blue square are visible.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          height: '144px',
          position: 'relative',
          overflow: 'scroll',
          width: '144px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            border: '5px blue solid',
            height: '96px',
            position: 'relative',
            top: '96px',
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
  xit('022', async () => {
    let p;
    let tallerAndWiderRelPos;
    let containingAncestor;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if, after scrolling down and to the right, all four edges of a blue square are visible.`
        ),
      ]
    );
    containingAncestor = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'containing-ancestor',
        style: {
          height: '144px',
          overflow: 'auto',
          width: '144px',
        },
      },
      [
        (tallerAndWiderRelPos = createElement('div', {
          id: 'taller-and-wider-rel-pos',
          style: {
            border: '5px solid blue',
            height: '96px',
            left: '72px',
            position: 'relative',
            top: '72px',
            width: '96px',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(containingAncestor);

    await snapshot();
  });
  it('027-ref', async () => {
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
      [createText(`Test passes if the 3 "Filler Text" are on the same line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text Filler Text Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('027', async () => {
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
      [createText(`Test passes if the 3 "Filler Text" are on the same line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          width: '480px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
            Filler Text `),
        createElement(
          'span',
          {
            style: {
              bottom: 'auto',
              left: 'auto',
              position: 'relative',
              right: 'auto',
              top: 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
        createText(` Filler Text
        `),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('028-ref', async () => {
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
      [createText(`Test passes if the 2 "Filler Text" are on the same line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('028', async () => {
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
      [createText(`Test passes if the 2 "Filler Text" are on the same line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          width: '480px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
        createText(` Filler Text
        `),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('029', async () => {
    let p;
    let span1;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the 2 "Filler Text" are on the same line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          width: '480px',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        )),
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(` Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('030-ref', async () => {
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
      [createText(`Test passes if the 4 "Filler Text" are on the same line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text Filler Text Filler Text Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('030', async () => {
    let p;
    let span1;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the 4 "Filler Text" are on the same line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          width: '480px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
            Filler Text `),
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        )),
        createText(` Filler Text`),
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(` Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('031-ref', async () => {
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
      [createText(`Test passes if the 5 "Filler Text" are on the same line.`)]
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
        createText(
          `Filler Text Filler Text Filler Text Filler Text Filler Text`
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('031', async () => {
    let p;
    let span1;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the 5 "Filler Text" are on the same line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          width: '480px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text `)]
        ),
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        )),
        createText(` Filler Text`),
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(` Filler Text `)]
        ),
        createText(`Filler Text
        `),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('032-ref', async () => {
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
          `Test passes if "Filler Text1" and "Filler Text3" are on the first line and "Filler Text2" is on the second line and the space has been reserved where "Filler Text2" would have been if it were on the first line.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'line-height': '1.25',
        },
      },
      [
        createText(`Filler Text1`),
        createElement(
          'span',
          {
            style: {
              visibility: 'hidden',
            },
          },
          [createText(`Filler Text2`)]
        ),
        createText(`Filler Text3`),
      ]
    );
    div_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'line-height': '1.25',
          'margin-top': '5px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              visibility: 'hidden',
            },
          },
          [createText(`Filler Text1`)]
        ),
        createText(`Filler Text2`),
        createElement(
          'span',
          {
            style: {
              visibility: 'hidden',
            },
          },
          [createText(`Filler Text3`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('032', async () => {
    let p;
    let span1;
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
          `Test passes if "Filler Text1" and "Filler Text3" are on the first line and "Filler Text2" is on the second line and the space has been reserved where "Filler Text2" would have been if it were on the first line.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'line-height': '1.25',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`Filler Text1`),
            (span1 = createElement(
              'span',
              {
                id: 'span1',
                style: {
                  position: 'relative',
                  top: '25px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`Filler Text2`)]
            )),
            createText(`Filler Text3`),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('033-ref', async () => {
    let p;
    let yellowStripe;
    let orangeStripe;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if the yellow stripe is on the left-hand side of the hollow blue rectangle and the orange stripe is on the right-hand side of the hollow blue rectangle.`
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
        createElement(
          'span',
          {
            style: {
              font: '20px/1 NaNpx',
              border: '2px solid blue',
            },
          },
          [
            (yellowStripe = createElement(
              'span',
              {
                id: 'yellow-stripe',
                style: {
                  font: '20px/1 NaNpx',
                  color: 'yellow',
                },
              },
              [createText(`123456`)]
            )),
            (orangeStripe = createElement(
              'span',
              {
                id: 'orange-stripe',
                style: {
                  font: '20px/1 NaNpx',
                  color: 'orange',
                },
              },
              [createText(`123456`)]
            )),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('033', async (done) => {
    let p;
    let span2;
    let span1;
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
          `Test passes if the yellow stripe is on the left-hand side of the hollow blue rectangle and the orange stripe is on the right-hand side of the hollow blue rectangle.`
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
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              color: 'orange',
              font: '20px/1 NaNpx',
              border: '2px solid blue',
              'box-sizing': 'border-box',
            },
          },
          [
            (span2 = createElement(
              'span',
              {
                id: 'span2',
                style: {
                  color: 'yellow',
                  font: '20px/1 NaNpx',
                  position: 'relative',
                  left: '-60px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`XXXXXX`)]
            )),
            createText(`XXXXXX`),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });
  xit('034', async () => {
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
          `Test passes if the box can be scrolled to the words "Filler Text".`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: 'solid',
          overflow: 'auto',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              position: 'relative',
              left: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });

  // @TODO Need to impl text anonymous box split
  xit('035-ref', async () => {
    let p;
    let black;
    let orange;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if a black rectangle has one and only one orange line of text below it.`
        ),
      ]
    );
    black = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'black',
        style: {
          'line-height': '1.25',
          width: '50px',
          'background-color': 'black',
          'margin-top': '20px',
        },
      },
      [createText(`Filler Text Filler Text Filler Text`)]
    );
    orange = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'orange',
        style: {
          'line-height': '1.25',
          width: '50px',
          'background-color': 'orange',
          'padding-top': '2.5px',
        },
      },
      [createText(`Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(black);
    BODY.appendChild(orange);

    await snapshot();
  });
  it('035', async () => {
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
          `Test passes if a black rectangle has one and only one orange line of text below it.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'line-height': '1.25',
          width: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              position: 'relative',
              top: '16px',
              background: 'black',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text Filler Text Filler Text`)]
        )),
        (div3 = createElement(
          'div',
          {
            id: 'div3',
            style: {
              background: 'orange',
              'box-sizing': 'border-box',
            },
          },
          [createText(` FAIL  Text`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('036', async () => {
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
          `Test passes if the box can be scrolled to the words "Filler Text".`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: 'solid',
          overflow: 'scroll',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              position: 'relative',
              left: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('037-ref', async () => {
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
          `Test passes if the right side of the hollow rectangle is blue.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '3px solid black',
          'text-align': 'right',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/swatch-blue.png',
          width: '96',
          height: '96',
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
  it('037', async () => {
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
          `Test passes if the right side of the hollow rectangle is blue.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '3px solid black',
          direction: 'ltr',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            height: '96px',
            left: '96px',
            position: 'relative',
            right: '192px',
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
  it('038-ref', async () => {
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
          `Test passes if the left side of the hollow rectangle is blue.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '3px solid black',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/swatch-blue.png',
          width: '96',
          height: '96',
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
  xit('038', async () => {
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
          `Test passes if the left side of the hollow rectangle is blue.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '1px solid 3px',
          direction: 'rtl',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            height: '96px',
            left: '192px',
            position: 'relative',
            right: '96px',
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
  it('nested-001-ref', async () => {
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
        'background-color': 'green',
        height: '300px',
        width: '200px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('nested-001', async () => {
    let p;
    let innerMost;
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
    outer = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'outer',
        style: {
          background: "green repeat-x center url('support/red_box.png')",
          height: '300px',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement(
          'div',
          {
            id: 'inner',
            style: {
              'background-color': 'red',
              height: '100px',
              position: 'relative',
              top: '50%',
              'box-sizing': 'border-box',
            },
          },
          [
            (innerMost = createElement('div', {
              id: 'inner-most',
              style: {
                'background-color': 'green',
                height: '150px',
                position: 'relative',
                top: '-50%',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outer);

    await snapshot();
  });
});
