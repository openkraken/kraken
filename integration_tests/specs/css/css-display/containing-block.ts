/*auto generated*/
describe('containing-block', () => {
  xit('001', async () => {
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
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          background: 'red',
          display: 'block',
          height: '100px',
          width: '100px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'green',
            height: '100%',
            position: 'relative',
            width: '100%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div1);

    await snapshot();
  });
  it('003', async () => {
    let div1;
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          background: 'red',
          display: 'inline-block',
          height: '60px',
          padding: '20px',
          width: '60px',
          left: '-20px',
          position: 'relative',
          top: '-20px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'green',
            height: '100px',
            left: '-20px',
            position: 'relative',
            top: '-20px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    document.body.appendChild(div1);

    await snapshot();
  });
  xit('004', async () => {
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
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          background: 'red',
          display: 'block',
          height: '100px',
          width: '100px',
          position: 'static',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'green',
            height: '100%',
            position: 'static',
            width: '100%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div1);

    await snapshot();
  });
  xit('006', async () => {
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
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          background: 'red',
          display: 'inline-block',
          height: '100px',
          width: '100px',
          position: 'static',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'green',
            height: '100%',
            position: 'static',
            width: '100%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div1);

    await snapshot();
  });
  it('007-ref', async () => {
    let p;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a filled blue square in the upper-right corner of the
		page.`),
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            position: 'absolute',
            right: '0px',
            top: '0px',
          },
        }),
      ]
    );
    document.body.appendChild(p);

    await snapshot(0.1);
  });
  it('007', async () => {
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
          `Test passes if there is a filled blue square in the upper-right corner of the page.`
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
          bottom: '0',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            height: '100px',
            position: 'fixed',
            right: '0',
            top: '0',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div1);

    await snapshot();
  });
  xit('008-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '10px solid black',
          height: '196px',
          'margin-left': '50px',
          position: 'absolute',
          top: '50px',
          width: '196px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            position: 'relative',
            left: '100px',
          },
        }),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot(0.5);
  });
  it('008', async () => {
    let p;
    let div3;
    let div2;
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '2px solid black',
          margin: '50px',
          position: 'absolute',
          top: '0',
          height: '100px',
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
              height: '100px',
              width: '100px',
              margin: '50px',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                height: '100px',
                width: '100px',
                background: 'blue',
                right: '0',
                position: 'absolute',
                top: '0',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div1);

    await snapshot();
  });
  it('009-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          height: '196px',
          margin: '50px',
          'text-align': 'right',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue96x96.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    document.body.appendChild(div);

    await snapshot(0.5);
  });
  it('009', async () => {
    let p;
    let div3;
    let div2;
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow wide black rectangle.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '2px solid black',
          margin: '50px',
          position: 'relative',
          top: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              height: '100px',
              width: '100px',
              margin: '50px',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                height: '100px',
                width: '100px',
                background: 'blue',
                right: '0',
                position: 'absolute',
                top: '0',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div1);

    await snapshot();
  });
  it('010', async () => {
    let p;
    let div3;
    let div2;
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`upper-right corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          border: '2px solid black',
          margin: '50px',
          position: 'fixed',
          top: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              height: '100px',
              width: '100px',
              margin: '50px',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                background: 'blue',
                right: '0',
                position: 'absolute',
                top: '0',
                height: '100px',
                width: '100px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div1);

    await snapshot();
  });
  it('011', async () => {
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
        createText(`Test passes if the filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`lower-right corner`)]
        ),
        createText(` of the hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          padding: '100px',
          position: 'relative',
          width: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              direction: 'ltr',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              style: {
                background: 'blue',
                height: '100px',
                position: 'absolute',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('013', async () => {
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
        createText(`Test passes if the filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`lower-right corner`)]
        ),
        createText(` of the hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          padding: '100px',
          position: 'absolute',
          width: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              direction: 'ltr',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              style: {
                background: 'blue',
                height: '100px',
                position: 'absolute',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('015', async () => {
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
        createText(`Test passes if the filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`lower-right corner`)]
        ),
        createText(` of the hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          padding: '100px',
          position: 'fixed',
          width: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              direction: 'ltr',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              style: {
                background: 'blue',
                height: '100px',
                position: 'absolute',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  xit('017', async () => {
    let p;
    let tlControl;
    let firstBox;
    let position;
    let position_1;
    let brControl;
    let lastBox;
    let test;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is no red visible on the page.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid silver',
          direction: 'ltr',
          'margin-bottom': '20px',
          padding: '100px',
          width: '450px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement(
          'span',
          {
            id: 'test',
            style: {
              border: '5px solid silver',
              padding: '50px',
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [
            (firstBox = createElement(
              'span',
              {
                id: 'first-box',
                style: {
                  color: 'silver',
                  'box-sizing': 'border-box',
                },
              },
              [
                (tlControl = createElement('span', {
                  id: 'tl-control',
                  style: {
                    'border-top': '30px solid red',
                    'margin-left': '-50px',
                    'margin-right': '20px',
                    padding: '20px 15px',
                    'box-sizing': 'border-box',
                  },
                })),
                createText(`Filler Text Filler Text Filler Text Filler Text`),
              ]
            )),
            (position = createElement(
              'span',
              {
                class: 'position bottom-right',
                style: {
                  height: '30px',
                  position: 'absolute',
                  width: '30px',
                  background: 'green',
                  bottom: '0',
                  right: '0',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`BR`)]
            )),
            (position_1 = createElement(
              'span',
              {
                class: 'position top-left',
                style: {
                  height: '30px',
                  position: 'absolute',
                  width: '30px',
                  background: 'green',
                  left: '0',
                  top: '0',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`TL`)]
            )),
            (lastBox = createElement(
              'span',
              {
                id: 'last-box',
                style: {
                  color: 'silver',
                  'box-sizing': 'border-box',
                },
              },
              [
                createText(`Filler Text Filler Text Filler Text Filler Text`),
                (brControl = createElement('span', {
                  id: 'br-control',
                  style: {
                    'border-bottom': '30px solid red',
                    'margin-left': '20px',
                    'margin-right': '-50px',
                    padding: '20px 15px',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            )),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  xit('018', async () => {
    await snapshot();
  });
  it('019-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          height: '96px',
          'padding-top': '96px',
          'text-align': 'right',
          width: '192px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue96x96.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    document.body.appendChild(div);

    await snapshot(0.1);
  });
  it('019', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`lower-right corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          padding: '100px',
          position: 'absolute',
          width: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              display: 'block',
              direction: 'ltr',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              style: {
                display: 'block',
                background: 'blue',
                height: '100px',
                left: 'auto',
                position: 'absolute',
                top: 'auto',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('020-ref', async (done) => {
    let p;
    let div;
    let img;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`lower-left corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          height: '96px',
          'padding-top': '96px',
          width: '192px',
        },
      },
      [
        img = createElement('img', {
          src: 'assets/blue96x96.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    img.onload = async () => {
      await snapshot();
      done();
    }
  });
  it('020', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`lower-left corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          padding: '100px',
          position: 'absolute',
          width: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              display: 'block',
              direction: 'rtl',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              style: {
                display: 'block',
                background: 'blue',
                height: '100px',
                left: 'auto',
                position: 'absolute',
                top: 'auto',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('021', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`lower-right corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          padding: '100px',
          position: 'fixed',
          width: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              display: 'block',
              direction: 'ltr',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              style: {
                display: 'block',
                background: 'blue',
                height: '100px',
                left: 'auto',
                position: 'absolute',
                top: 'auto',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('022', async () => {
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
        createText(`Test passes if a filled blue square is in the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`lower-left corner`)]
        ),
        createText(` of an hollow black square.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          border: '2px solid black',
          padding: '100px',
          position: 'fixed',
          width: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        (span1 = createElement(
          'span',
          {
            id: 'span1',
            style: {
              display: 'block',
              direction: 'rtl',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              style: {
                display: 'block',
                background: 'blue',
                height: '100px',
                left: 'auto',
                position: 'absolute',
                top: 'auto',
                width: '100px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('023', async () => {
    let p;
    let div3;
    let div2;
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
        createText(`Test passes if a blue square is at the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`bottom-left corner`)]
        ),
        createText(` of the page.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          margin: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement(
          'div',
          {
            id: 'div2',
            style: {
              margin: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            (div3 = createElement('div', {
              id: 'div3',
              style: {
                background: 'blue',
                height: '100px',
                left: '0',
                position: 'absolute',
                bottom: '0',
                width: '100px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div1);

    await snapshot();
  });
  it('026', async () => {
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'green',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            background: 'green',
            height: '100px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('027', async () => {
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
        createText(
          `Test passes if the orange rectangle is within or overflows to the right and outside of the blue square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'blue',
          height: '300px',
          'padding-top': '5px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('div', {
          id: 'child',
          style: {
            background: 'orange',
            height: '100px',
            'padding-top': '5px',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('028', async () => {
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
        createText(
          `Test passes if a small orange square is in the bottom right corner of the blue square.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'blue',
          height: '100px',
          position: 'absolute',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('div', {
          id: 'child',
          style: {
            background: 'orange',
            height: '25px',
            position: 'absolute',
            width: '25px',
            bottom: '0',
            right: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(div);

    await snapshot();
  });
  it('030', async () => {
    let p;
    let soleChildWithTallerContent;
    let containingBlock;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if the orange rectangle is within or overflows below and outside of the blue square.`
        ),
      ]
    );
    containingBlock = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'containing-block',
        style: {
          'background-color': 'blue',
          height: '100px',
          'padding-left': '5px',
          width: '100px',
        },
      },
      [
        (soleChildWithTallerContent = createElement('div', {
          id: 'sole-child-with-taller-content',
          style: {
            'background-color': 'orange',
            height: '200px',
            width: '50px',
          },
        })),
      ]
    );
    document.body.appendChild(p);
    document.body.appendChild(containingBlock);

    await snapshot();
  });

  it('with transform', async () => {
    let root;
    let containingBlock;
    root = createElement(
      'div',
      {
        style: {
           background: '#999',
           width: '200px',
           height: '200px',
           padding: '50px',
        },
      }
    );
    containingBlock = createElement(
      'div',
      {
        style: {
          'transform': 'translate3d(0, 0, 0)',
          'background-color': 'blue',
          height: '100px',
          'padding-left': '5px',
          width: '100px',
        },
      },
      [
        (createElement('div', {
          style: {
            position: 'absolute',
            'background-color': 'orange',
            height: '50px',
            width: '50px',
            top: '25px',
            left: '25px',
          },
        })),
      ]
    );
    document.body.appendChild(root);
    root.appendChild(containingBlock);

    await snapshot();
  });

  it('without transform', async () => {
    let root;
    let containingBlock;
    root = createElement(
      'div',
      {
        style: {
           background: '#999',
           width: '200px',
           height: '200px',
           padding: '50px',
        },
      }
    );
    containingBlock = createElement(
      'div',
      {
        style: {
          'background-color': 'blue',
          height: '100px',
          'padding-left': '5px',
          width: '100px',
        },
      },
      [
        (createElement('div', {
          style: {
            position: 'absolute',
            'background-color': 'orange',
            height: '50px',
            width: '50px',
            top: '25px',
            left: '25px',
          },
        })),
      ]
    );
    document.body.appendChild(root);
    root.appendChild(containingBlock);

    await snapshot();
  });
});
