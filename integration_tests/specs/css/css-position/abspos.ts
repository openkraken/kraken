/*auto generated*/
describe('abspos', () => {
  it('001', async () => {
    let margin;
    let abs;
    let flow;
    margin = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'margin',
        style: {
          margin: '0',
          padding: '0',
          border: '0',
          position: 'static',
          float: 'none',
          display: 'block',
          top: 'auto',
          left: 'auto',
          right: 'auto',
          bottom: 'auto',
          'margin-bottom': '20px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a green stripe and no red.`)]
    );
    abs = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'abs',
      style: {
        margin: '0',
        padding: '0',
        border: '0',
        position: 'absolute',
        float: 'none',
        display: 'block',
        top: 'auto',
        left: 'auto',
        right: 'auto',
        bottom: 'auto',
        background: 'green',
        'z-index': '1',
        height: '10px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    flow = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'flow',
      style: {
        margin: '0',
        padding: '0',
        border: '0',
        position: 'static',
        float: 'none',
        display: 'block',
        top: 'auto',
        left: 'auto',
        right: 'auto',
        bottom: 'auto',
        background: 'red',
        height: '10px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(margin);
    BODY.appendChild(abs);
    BODY.appendChild(flow);

    await snapshot();
  });
  xit('002', async () => {
    let p;
    let test;
    let container;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a hollow blue rectangle.`)]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          position: 'relative',
          background: 'red',
          width: '60px',
          'border-top': '1em solid blue',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [
                (test = createElement('div', {
                  class: 'test',
                  style: {
                    position: 'absolute',
                    height: '20px',
                    width: '40px',
                    background: 'white',
                    color: 'green',
                    border: 'solid 1em blue',
                    'border-top': 'none',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('003', async () => {
    let absolute;
    let control;
    absolute = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'absolute',
        style: {
          margin: '0',
          padding: '0',
          position: 'absolute',
          bottom: '0',
          left: '0',
          right: '0',
          height: '50px',
          border: '1px solid blue',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`This blue box should be at the bottom of the viewport
    / first page.`),
      ]
    );
    control = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          margin: '0',
          padding: '0',
          border: '1px solid yellow',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`This yellow box should be at the top of the
    viewport or first page. There should also be a blue box visible at the
    bottom of the viewport / page. `),
      ]
    );
    BODY.appendChild(absolute);
    BODY.appendChild(control);

    await snapshot();
  });
  it('004', async () => {
    let absolute;
    let control;
    absolute = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'absolute',
        style: {
          position: 'absolute',
          bottom: '0',
          left: '0',
          right: '0',
          height: '50px',
          border: '1px solid blue',
          margin: '0',
          padding: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`This blue box should be at the bottom of the viewport
    / first page.`),
      ]
    );
    control = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          border: '1px solid yellow',
          margin: '0',
          padding: '0',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`This yellow box should be at the top of the
    viewport or first page. There should also be a blue box visible at the
    bottom of the viewport / page.`),
      ]
    );
    BODY.appendChild(absolute);
    BODY.appendChild(control);

    await snapshot();

    await snapshot();
  });
  xit('006', async () => {
    let description;
    let control;
    description = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'description',
        style: {
          font: 'medium serif',
          margin: '10px 10px 150px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `The word PASS should appear at the bottom right of this document.`
        ),
      ]
    );
    control = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          position: 'absolute',
          bottom: '0',
          left: 'auto',
          right: '0',
          top: 'auto',
          background: 'red',
          color: 'yellow',
          margin: '0',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    BODY.appendChild(description);
    BODY.appendChild(control);

    await snapshot();
  });
  it('007', async () => {
    let test;
    let control;
    let inline;
    let container;
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (inline = createElement(
          'div',
          {
            class: 'inline',
            style: {
              height: '10px',
              width: '100px',
              display: 'inline',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
     Test passes if there is `),
            createElement(
              'strong',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`no red`)]
            ),
            createText(`.
     `),
            (test = createElement('div', {
              class: 'test',
              style: {
                height: '10px',
                width: '100px',
                position: 'absolute',
                background: 'green',
                'z-index': '1',
                'box-sizing': 'border-box',
              },
            })),
            (control = createElement('div', {
              class: 'control',
              style: {
                height: '10px',
                width: '100px',
                background: 'red',
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
  xit('008', async () => {
    let p;
    let inner;
    let outer;
    let control;
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
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          'font-size': '100px',
          position: 'relative',
          'border-top': '10px solid white',
          'box-sizing': 'border-box',
        },
      },
      [
        (outer = createElement(
          'div',
          {
            class: 'outer',
            style: {
              position: 'absolute',
              top: '0',
              left: '0',
              'z-index': '1',
              'box-sizing': 'border-box',
            },
          },
          [
            (inner = createElement(
              'div',
              {
                class: 'inner',
                style: {
                  background: 'green',
                  color: 'white',
                  float: 'left',
                  'box-sizing': 'border-box',
                },
              },
              [
                createText(`
     X X0
    `),
              ]
            )),
          ]
        )),
        (control = createElement(
          'div',
          {
            class: 'control',
            style: {
              float: 'left',
              color: 'yellow',
              background: 'red',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X X1`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('009', async () => {
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
      [
        createText(`Test passes if there is a green stripe on the right and `),
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
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'test',
      style: {
        position: 'absolute',
        width: '100px',
        height: '10px',
        right: '0',
        margin: 'auto',
        background: 'green',
        color: 'white',
        'box-sizing': 'border-box',
      },
    });
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'border-right': '30px solid red',
        height: '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(control);

    await snapshot();
  });
  xit('010', async () => {
    let p;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a green block and no red below.`)]
    );
    BODY.appendChild(p);

    await snapshot();
  });
  xit('011', async () => {
    let p;
    let p_1;
    let p_2;
    let p_3;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'absolute',
          font: 'bold 32px/1 monospace',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL     `)]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'absolute',
          font: 'bold 32px/1 monospace',
          'box-sizing': 'border-box',
        },
      },
      [createText(`#    P   `)]
    );
    p_2 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'absolute',
          font: 'bold 32px/1 monospace',
          'box-sizing': 'border-box',
        },
      },
      [createText(` ##   A  `)]
    );
    p_3 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          position: 'absolute',
          font: 'bold 32px/1 monospace',
          'box-sizing': 'border-box',
        },
      },
      [createText(`   #   SS`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);
    BODY.appendChild(p_2);
    BODY.appendChild(p_3);

    await snapshot();
  });
  xit('013', async () => {
    let a;
    let b;
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'fixed',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    BODY.appendChild(a);
    BODY.appendChild(b);

    await snapshot();
  });
  it('014', async () => {
    let b;
    let a;
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'static',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    BODY.appendChild(b);
    BODY.appendChild(a);

    await snapshot();
  });
  xit('015', async () => {
    let a;
    let b;
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'fixed',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    BODY.appendChild(a);
    BODY.appendChild(b);

    await snapshot();
  });
  it('016', async () => {
    let b;
    let a;
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'static',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    BODY.appendChild(b);
    BODY.appendChild(a);

    await snapshot();
  });
  it('017', async () => {
    let a;
    let b;
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'fixed',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    BODY.appendChild(a);
    BODY.appendChild(b);

    await snapshot();
  });
  it('018', async () => {
    let b;
    let a;
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'static',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    BODY.appendChild(b);
    BODY.appendChild(a);

    await snapshot();
  });
  xit('019', async () => {
    let a;
    let b;
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'fixed',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    BODY.appendChild(a);
    BODY.appendChild(b);

    await snapshot();
  });
  it('020', async () => {
    let b;
    let a;
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'static',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    BODY.appendChild(b);
    BODY.appendChild(a);

    await snapshot();
  });
  xit('022', async () => {
    let c3;
    let c2;
    let c1;
    let b;
    let a;
    let c4;
    c1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'c1',
        style: {
          margin: '2px',
          'box-sizing': 'border-box',
        },
      },
      [
        (c2 = createElement(
          'div',
          {
            class: 'c2',
            style: {
              margin: '-4px 20px',
              'box-sizing': 'border-box',
            },
          },
          [
            (c3 = createElement('div', {
              class: 'c3',
              style: {
                margin: '0 0 14px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    b = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'b',
        style: {
          position: 'fixed',
          top: 'auto',
          left: 'auto',
          width: '200px',
          height: '40px',
          background: 'green',
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`This block should be green.`)]
    );
    a = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'a',
        style: {
          position: 'static',
          top: '10px',
          left: '10px',
          width: '200px',
          height: '40px',
          background: 'red',
          color: 'yellow',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    c4 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'c4',
      style: {
        margin: '50px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(c1);
    BODY.appendChild(b);
    BODY.appendChild(a);
    BODY.appendChild(c4);

    await snapshot();
  });
  xit('023', async () => {
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
      [
        createText(
          `There should be a green square roughly centered below and no red.`
        ),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          position: 'absolute',
          left: '50%',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          class: 'test',
          style: {
            position: 'fixed',
            left: 'auto',
            width: '10px',
            height: '10px',
            background: 'green',
            color: 'white',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'margin-left': '50%',
        'border-top': '1em solid red',
        width: '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(control);

    await snapshot();
  });
  xit('024', async () => {
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
      [
        createText(`Test passes if there is a green stripe on the right and `),
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
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'test',
      style: {
        position: 'absolute',
        background: 'green',
        color: 'green',
        width: '40px',
        height: '10px',
        'box-sizing': 'border-box',
      },
    });
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        'border-right': '4em solid red',
        height: '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(control);

    await snapshot();
  });
  it('025', async () => {
    let p;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a green square and `),
        createElement(
          'strong',
          {
            style: {
              'line-height': '1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`. `),
        createElement('img', {
          src: 'assets/swatch-green.png',
          alt: 'FAIL',
          style: {
            position: 'absolute',
            left: '40px',
            right: '0',
            top: '40px',
            bottom: '0',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);

    await snapshot(0.1);
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
        createText(`Test passes if there is a green square and `),
        createElement(
          'strong',
          {
            style: {
              'line-height': '1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`. `),
        createElement('img', {
          src: 'assets/swatch-red.png',
          alt: 'FAIL',
          style: {
            position: 'absolute',
            left: '40px',
            right: '40px',
            top: '40px',
            bottom: '40px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        position: 'absolute',
        left: '40px',
        top: '40px',
        height: '15px',
        width: '15px',
        background: 'green',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
