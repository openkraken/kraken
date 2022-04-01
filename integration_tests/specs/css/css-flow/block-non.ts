/*auto generated*/
describe('block-non', () => {
  it('replaced-height-001-ref', async () => {
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
          [createText(`no space between`)]
        ),
        createText(` the blue stripe and the orange lines.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'blue',
          'border-bottom': '10px solid orange',
          'border-top': '10px solid orange',
          width: '100px',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('replaced-height-001', async () => {
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
          [createText(`no space between`)]
        ),
        createText(` the blue stripe and the orange lines.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-bottom': '2px solid orange',
          'border-top': '2px solid orange',
          width: '100px',
          background: 'blue',
          'margin-bottom': 'auto',
          'margin-top': 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'blue',
              'margin-bottom': 'auto',
              'margin-top': 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-height-002', async () => {
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
          `Test passes if there is no white space between the blue box below and the orange lines.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-bottom': '2px solid orange',
          'border-top': '2px solid orange',
          width: '100px',
          background: 'blue',
          'margin-bottom': 'auto',
          'margin-top': 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'blue',
              'margin-bottom': 'auto',
              'margin-top': 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-height-003', async () => {
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
          `Test passes if the blue and orange boxes below are the same height.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            id: 'div1',
            style: {
              position: 'relative',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                position: 'relative',
                width: '100px',
                background: 'blue',
                height: '200px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            position: 'absolute',
            width: '100px',
            background: 'orange',
            height: '200px',
            left: '100px',
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
  it('replaced-height-004', async () => {
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
          `Test passes if the blue and orange boxes below are the same height.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            id: 'div1',
            style: {
              position: 'relative',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                position: 'relative',
                width: '100px',
                background: 'blue',
                height: '200px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            position: 'absolute',
            width: '100px',
            background: 'orange',
            height: '200px',
            left: '100px',
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
  it('replaced-height-005-ref', async () => {
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
          `Test passes if the blue and orange squares have the same height and if there is `
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
          width: '200',
          height: '200',
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          width: '200',
          height: '200',
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

  it('replaced-height-005', async () => {
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
          `Test passes if the blue and orange squares have the same height and if there is `
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
        (div1 = createElement(
          'div',
          {
            id: 'div1',
            style: {
              position: 'relative',
              background: 'red',
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  color: 'blue',
                  display: 'inline',
                  font: '100px/1 Ahem',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`XX XX`)]
            ),
          ]
        )),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            position: 'absolute',
            background: 'orange',
            height: '200px',
            left: '200px',
            top: '0',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });

  it('replaced-height-006', async () => {
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
          `Test passes if the blue and orange squares have the same height and if there is `
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
        (div1 = createElement(
          'div',
          {
            id: 'div1',
            style: {
              position: 'relative',
              background: 'red',
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  color: 'blue',
                  display: 'inline',
                  font: '100px/1 Ahem',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`XX XX`)]
            ),
          ]
        )),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            position: 'absolute',
            background: 'orange',
            height: '200px',
            left: '200px',
            top: '0',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('replaced-height-007', async () => {
    let p;
    let div2;
    let div3;
    let div4;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a blue square below.`)]
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
            width: '100px',
            background: 'blue',
            height: '50px',
            'border-top': '0.5in solid blue',
            'margin-top': '50px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            width: '100px',
            background: 'blue',
            height: '50px',
            'border-bottom': '0.5in solid blue',
            'margin-bottom': '50px',
            'box-sizing': 'border-box',
          },
        })),
        (div4 = createElement('div', {
          id: 'div4',
          style: {
            width: '100px',
            background: 'blue',
            height: '200px',
            left: '100px',
            position: 'absolute',
            top: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-height-008', async () => {
    let p;
    let div2;
    let div3;
    let div4;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a blue square below.`)]
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
            width: '100px',
            background: 'blue',
            height: '50px',
            'border-top': '0.5in solid blue',
            'margin-top': '50px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            width: '100px',
            background: 'blue',
            height: '50px',
            'border-bottom': '0.5in solid blue',
            'margin-bottom': '50px',
            'box-sizing': 'border-box',
          },
        })),
        (div4 = createElement('div', {
          id: 'div4',
          style: {
            width: '100px',
            background: 'blue',
            height: '200px',
            left: '100px',
            position: 'absolute',
            top: '0',
            'box-sizing': 'border-box',
          },
        })),
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
      [createText(`Test passes if there is a blue square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'blue',
        height: '200px',
        width: '200px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('replaced-height-009', async () => {
    let p;
    let div3;
    let div4;
    let div2;
    let div5;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a blue square.`)]
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
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              background: 'blue',
              'border-bottom': '0.25in solid blue',
              'border-top': '0.25in solid blue',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                width: '100px',
                background: 'blue',
                height: '25px',
                'border-top': '0.25in solid blue',
                'margin-top': '25px',
                'box-sizing': 'border-box',
              },
            })),
            (div4 = createElement('div', {
              id: 'div4',
              style: {
                width: '100px',
                background: 'blue',
                height: '25px',
                'border-bottom': '0.25in solid blue',
                'margin-bottom': '25px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (div5 = createElement('div', {
          id: 'div5',
          style: {
            width: '100px',
            background: 'blue',
            height: '200px',
            left: '100px',
            position: 'absolute',
            top: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-height-010', async () => {
    let p;
    let div3;
    let div4;
    let div2;
    let div5;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a blue square below.`)]
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
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              background: 'blue',
              'border-bottom': '0.25in solid blue',
              'border-top': '0.25in solid blue',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                width: '100px',
                background: 'blue',
                height: '25px',
                'border-top': '0.25in solid blue',
                'margin-top': '25px',
                'box-sizing': 'border-box',
              },
            })),
            (div4 = createElement('div', {
              id: 'div4',
              style: {
                width: '100px',
                background: 'blue',
                height: '25px',
                'border-bottom': '0.25in solid blue',
                'margin-bottom': '25px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (div5 = createElement('div', {
          id: 'div5',
          style: {
            width: '100px',
            background: 'blue',
            height: '200px',
            left: '100px',
            position: 'absolute',
            top: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('replaced-height-013', async () => {
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
          background: 'red',
          height: 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('div', {
          id: 'child',
          style: {
            height: '100px',
            overflow: 'visible',
            position: 'absolute',
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
  it('replaced-height-014', async () => {
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
          background: 'red',
          height: 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('div', {
          id: 'child',
          style: {
            height: '100px',
            overflow: 'scroll',
            position: 'absolute',
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
  it('replaced-height-015', async () => {
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
          `Test passes if the blue and orange boxes below are the same height.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              background: 'blue',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                position: 'relative',
                top: '100px',
                height: '100px',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            background: 'orange',
            left: '100px',
            position: 'absolute',
            top: '0',
            height: '100px',
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
  it('replaced-height-016', async () => {
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
          `Test passes if the blue and orange boxes below are the same height.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              background: 'blue',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                position: 'relative',
                top: '100px',
                height: '100px',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            background: 'orange',
            left: '100px',
            position: 'absolute',
            top: '0',
            height: '100px',
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
  it('replaced-width-001-ref', async () => {
    let p;
    let orange;
    let blue;
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
          [createText(`same width`)]
        ),
        createText(`.`),
      ]
    );
    orange = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'orange',
      style: {
        height: '30px',
        width: '150px',
        'background-color': 'orange',
      },
    });
    blue = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'blue',
      style: {
        height: '30px',
        width: '150px',
        'background-color': 'blue',
        position: 'absolute',
        top: '82px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(orange);
    BODY.appendChild(blue);

    await snapshot();
  });
  it('replaced-width-001', async () => {
    let p;
    let div1;
    let d3;
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
          [createText(`same width`)]
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
          'background-color': 'orange',
          border: '5px solid orange',
          display: 'inline-block',
          'border-left': '10px solid orange',
          'border-right': '10px solid orange',
          height: '20px',
          'margin-left': '10px',
          'margin-right': '10px',
          'padding-left': '10px',
          'padding-right': '10px',
          width: '80px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'orange',
            'border-left': '10px solid orange',
            'border-right': '10px solid orange',
            height: '20px',
            'margin-left': '10px',
            'margin-right': '10px',
            'padding-left': '10px',
            'padding-right': '10px',
            width: '80px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    d3 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'd3',
      style: {
        'background-color': 'blue',
        'border-left': '10px solid orange',
        'border-right': '10px solid orange',
        height: '30px',
        'margin-left': '10px',
        'margin-right': '10px',
        'padding-left': '10px',
        'padding-right': '10px',
        width: '150px',
        position: 'absolute',
        top: '82px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(d3);

    await snapshot();
  });
  it('replaced-width-002', async () => {
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
        createText(`Test passes if the orange and blue rectangles have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same width`)]
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
          'margin-top': '15px',
          width: '100px',
          'background-color': 'orange',
          'border-left': '10px solid orange',
          'border-right': '10px solid orange',
          height: '30px',
          'margin-left': 'auto',
          'padding-left': '10px',
          'padding-right': '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'orange',
            'border-left': '10px solid orange',
            'border-right': '10px solid orange',
            height: '30px',
            'margin-left': 'auto',
            'padding-left': '10px',
            'padding-right': '10px',
            width: '110px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        'background-color': 'blue',
        'border-left': '10px solid orange',
        'border-right': '10px solid orange',
        height: '30px',
        'margin-left': 'auto',
        'padding-left': '10px',
        'padding-right': '10px',
        width: '150px',
        position: 'absolute',
        top: '82px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
  it('replaced-width-003', async () => {
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
        createText(`Test passes if the orange and blue rectangles have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same width`)]
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
          direction: 'ltr',
          background: 'orange',
          width: '100px',
          'background-color': 'orange',
          'border-left': '10px solid orange',
          'border-right': '10px solid orange',
          height: '30px',
          'margin-left': '10px',
          'margin-right': '10px',
          'padding-left': '10px',
          'padding-right': '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'ltr',
            'background-color': 'orange',
            'border-left': '10px solid orange',
            'border-right': '10px solid orange',
            height: '30px',
            'margin-left': '10px',
            'margin-right': '10px',
            'padding-left': '10px',
            'padding-right': '10px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    div2 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'div2',
      style: {
        direction: 'ltr',
        'background-color': 'blue',
        'border-left': '10px solid orange',
        'border-right': '10px solid orange',
        height: '30px',
        'margin-left': '10px',
        'margin-right': '10px',
        'padding-left': '10px',
        'padding-right': '10px',
        width: '150px',
        position: 'absolute',
        top: '82px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
  it('replaced-width-004-ref', async () => {
    let p;
    let orange;
    let blue;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createText(`Test passes if the orange and blue rectangles have the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`same width`)]
        ),
        createText(`.`),
      ]
    );
    orange = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'orange',
      style: {
        height: '30px',
        width: '150px',
        'background-color': 'orange',
      },
    });
    blue = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'blue',
      style: {
        height: '30px',
        width: '150px',
        'background-color': 'blue',
        position: 'absolute',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(orange);
    BODY.appendChild(blue);

    await snapshot();
  });
  it('replaced-width-004', async () => {
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
        createText(`Test passes if the orange and blue rectangles have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same width`)]
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
        (div1 = createElement(
          'div',
          {
            id: 'div1',
            style: {
              position: 'relative',
              background: 'orange',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                position: 'relative',
                'background-color': 'orange',
                'border-left': '10px solid orange',
                'border-right': '10px solid orange',
                height: '30px',
                'margin-left': '10px',
                'margin-right': '10px',
                'padding-left': '10px',
                'padding-right': '10px',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            position: 'absolute',
            'background-color': 'blue',
            height: '30px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('replaced-width-005-ref', async () => {
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
          `Test passes if a filled green rectangle spans the entire width of the page and if there is `
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
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'green',
        height: '40px',
        width: '100%',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('replaced-width-006', async () => {
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
          `Test passes if a filled green rectangle spans the entire width of the page and if there is `
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
          background: 'red',
          width: '100%',
          'background-color': 'green',
          border: '10px solid green',
          margin: '0 auto',
          padding: '0',
          height: '20px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            border: '10px solid green',
            margin: '0 auto',
            padding: '0',
            height: '20px',
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
  it('replaced-width-007-ref', async () => {
    let p;
    let orange;
    let blue;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if the blue and orange squares have the same width and the blue square is directly below the orange square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          height: '200px',
          'text-align': 'center',
          width: '200px',
        },
      },
      [
        (orange = createElement(
          'span',
          {
            id: 'orange',
            style: {
              color: 'orange',
              'font-size': '100px',
            },
          },
          [createText(`O`)]
        )),
        (blue = createElement(
          'span',
          {
            id: 'blue',
            style: {
              color: 'blue',
              'font-size': '100px',
            },
          },
          [createText(`B`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });

  it('replaced-width-007', async () => {
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
          `Test passes if the blue and orange squares have the same width and the blue square is directly below the orange square.`
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
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            'background-color': 'orange',
            'border-color': 'orange',
            'border-style': 'solid',
            'border-width': '25px',
            margin: '0 auto',
            padding: '0',
            height: '100px',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement(
          'div',
          {
            id: 'div3',
            style: {
              color: 'blue',
              font: '100px/1 Ahem',
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

    await snapshot();
  });

  it('replaced-width-008', async () => {
    let p;
    let child;
    let containingBlock;
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
    containingBlock = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'containing-block',
        style: {
          height: '200px',
          'border-right': 'red solid 200px',
          'padding-right': '200px',
          width: '0px',
        },
      },
      [
        (child = createElement('div', {
          id: 'child',
          style: {
            height: '200px',
            'border-right': 'green solid 200px',
            'margin-right': '-400px',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(containingBlock);

    await snapshot();
  });
});
