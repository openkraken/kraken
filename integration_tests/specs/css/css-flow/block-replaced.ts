/*auto generated*/
describe('block-replaced', () => {
  it('height-001-ref', async () => {
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
          `Test passes if there is no white space between the blue square and the orange lines.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'border-bottom': '2px solid orange',
          'border-top': '2px solid orange',
          'line-height': '15px',
          width: '96px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
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
  it('height-001', async () => {
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
          `Test passes if there is no white space between the blue square and the orange lines.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'border-bottom': '2px solid orange',
          'border-top': '2px solid orange',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            display: 'block',
            'margin-top': 'auto',
            'margin-bottom': 'auto',
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
        createText(
          `Test passes if the blue and orange boxes below are the same height.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'line-height': '0',
          position: 'absolute',
          background: 'orange',
          height: '100px',
          left: '100px',
          top: '0',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            display: 'inline',
            height: 'auto',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'line-height': '0',
            position: 'absolute',
            background: 'orange',
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
        border: '10px solid green',
        height: '150px',
        width: '300px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('height-004', async () => {
    let p;
    let child;
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
        (child = createElement('div', {
          id: 'child',
          style: {
            position: 'absolute',
            border: '2px solid green',
            height: '150px',
            top: '0',
            width: '300px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
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
          height: '200px',
          border: '2px solid green',
          top: '0',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            border: '2px solid green',
            height: '100px',
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
          `Test passes if the blue and orange squares have the same width and are horizontally centered inside the black hollow square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '2px solid black',
          height: '200px',
          width: '200px',
          color: 'orange',
          font: '15px/10px Ahem',
          'text-align': 'center',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            display: 'block',
            'margin-left': 'auto',
            'margin-right': 'auto',
            'box-sizing': 'border-box',
          },
        }),
        createElement(
          'div',
          {
            style: {
              color: 'orange',
              font: '15px/10px Ahem',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
  it('width-002-ref', async () => {
    let p;
    let blue;
    let orange;
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
          [createText(`same width`)]
        ),
        createText(
          ` and the blue rectangle is in the upper-left corner of an hollow black square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          height: '288px',
          width: '288px',
        },
      },
      [
        (blue = createElement(
          'span',
          {
            id: 'blue',
            style: {
              color: 'blue',
              'font-size': '50px',
            },
          },
          [createText(`1234`)]
        )),
        (orange = createElement(
          'span',
          {
            id: 'orange',
            style: {
              color: 'orange',
              'font-size': '50px',
            },
          },
          [createText(`1234`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('width-002', async () => {
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
        createText(`Test passes if the blue and orange rectangles have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same width`)]
        ),
        createText(
          ` and the blue rectangle is in the upper-left corner of an hollow black square.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: 'solid black',
          height: '300px',
          width: '300px',
          background: 'orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'svg:svg',
          {
            'xmlns:svg': 'http://www.w3.org/2000/svg',
            version: '1.1',
            height: '50',
            baseprofile: 'full',
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('svg:rect', {
              x: '0',
              y: '0',
              width: '200',
              height: '100',
              fill: 'blue',
              style: {
                'box-sizing': 'border-box',
              },
            }),
          ]
        ),
        createElement('div', {
          style: {
            background: 'orange',
            height: '50px',
            width: '200px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('width-003', async () => {
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
          `Test passes if the blue and orange boxes below are the same width, and the blue box is in the upper-left corner of the black box.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: 'solid black',
          height: '300px',
          width: '300px',
          background: 'orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'svg:svg',
          {
            'xmlns:svg': 'http://www.w3.org/2000/svg',
            version: '1.1',
            height: '50',
            baseprofile: 'full',
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('svg:rect', {
              x: '0',
              y: '0',
              width: '200',
              height: '100',
              fill: 'blue',
              style: {
                'box-sizing': 'border-box',
              },
            }),
          ]
        ),
        createElement('div', {
          style: {
            background: 'orange',
            height: '100px',
            width: '200px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  xit('width-004', async () => {
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
          `Test passes if the blue and orange boxes below are the same width, and the blue box is in the upper-left corner of the black box.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: 'solid black',
          height: '300px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              height: '110px',
              width: '300px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'svg:svg',
              {
                'xmlns:svg': 'http://www.w3.org/2000/svg',
                version: '1.1',
                baseprofile: 'full',
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [
                createElement('svg:rect', {
                  x: '0',
                  y: '0',
                  width: '200',
                  height: '100',
                  fill: 'blue',
                  style: {
                    'box-sizing': 'border-box',
                  },
                }),
              ]
            ),
          ]
        )),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            background: 'orange',
            height: '100px',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('width-006-ref', async () => {
    let p;
    let blue;
    let orange;
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
          [createText(`same width`)]
        ),
        createText(` and if they are `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`horizontally centered`)]
        ),
        createText(` inside an hollow black rectangle.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '10px solid black',
          height: '300px',
          'text-align': 'center',
          width: '200px',
        },
      },
      [
        (blue = createElement(
          'span',
          {
            id: 'blue',
            style: {
              color: 'blue',
              'font-size': '100px',
            },
          },
          [createText(`1`)]
        )),
        createElement('br', {
          style: {},
        }),
        (orange = createElement(
          'span',
          {
            id: 'orange',
            style: {
              color: 'orange',
              'font-size': '100px',
            },
          },
          [createText(`2`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('width-006', async () => {
    let p;
    let child;
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
          [createText(`same width`)]
        ),
        createText(` and if they are `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`horizontally centered`)]
        ),
        createText(` inside an hollow black rectangle.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '2px solid black',
          height: '300px',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          width: '50%',
          style: {
            display: 'block',
            'margin-left': 'auto',
            'margin-right': 'auto',
            'box-sizing': 'border-box',
          },
        }),
        (child = createElement(
          'div',
          {
            id: 'child',
            style: {
              color: 'orange',
              font: '100px/10px Ahem',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot(0.1);
  });
});
