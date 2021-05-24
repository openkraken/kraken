/*auto generated*/
describe('abspos-overflow', () => {
  it('001-ref', async () => {
    let positioned;
    let p;
    let overflow;
    positioned = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'positioned',
        style: {
          background: 'green',
          color: 'white',
          left: '0',
          position: 'absolute',
          top: '0',
          width: '100px',
        },
      },
      [createText(`PASS`)]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-top': '36px',
        },
      },
      [createText(`Ignore the scrollbars below.`)]
    );
    overflow = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'overflow',
      style: {
        height: '80px',
        overflow: 'scroll',
        width: '80px',
      },
    });
    BODY.appendChild(positioned);
    BODY.appendChild(p);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('001', async () => {
    let control;
    let p;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          color: 'yellow',
          background: 'red',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Ignore the scrollbars below.`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          width: '80px',
          height: '80px',
          overflow: 'scroll',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              color: 'white',
              background: 'green',
              position: 'absolute',
              top: '0',
              left: '0',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(p);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('002-ref', async () => {
    let positioned;
    let p;
    let overflow;
    positioned = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'positioned',
        style: {
          background: 'green',
          color: 'white',
          right: '0',
          position: 'absolute',
          top: '0',
          width: '100px',
        },
      },
      [createText(`PASS`)]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-top': '36px',
        },
      },
      [createText(`Ignore the scrollbars below.`)]
    );
    overflow = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'overflow',
      style: {
        height: '80px',
        overflow: 'scroll',
        width: '80px',
      },
    });
    BODY.appendChild(positioned);
    BODY.appendChild(p);
    BODY.appendChild(overflow);

    await snapshot();
  });
  xit('002', async () => {
    let control;
    let p;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          color: 'yellow',
          background: 'red',
          width: '100px',
          margin: '0 0 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Ignore the scrollbars below.`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          width: '80px',
          height: '80px',
          overflow: 'scroll',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              color: 'white',
              background: 'green',
              position: 'absolute',
              top: '0',
              right: '0',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(p);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('003-ref', async () => {
    let positioned;
    let p;
    let overflow;
    positioned = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'positioned',
        style: {
          background: 'green',
          color: 'white',
          height: '50px',
          left: '50px',
          position: 'absolute',
          top: '50px',
          width: '50px',
        },
      },
      [createText(`PASS`)]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-top': '110px',
        },
      },
      [createText(`Ignore the scrollbars below.`)]
    );
    overflow = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'overflow',
      style: {
        height: '80px',
        overflow: 'scroll',
        width: '80px',
      },
    });
    BODY.appendChild(positioned);
    BODY.appendChild(p);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('003', async () => {
    let control;
    let p;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          margin: '50px 0 0 50px',
          background: 'red',
          color: 'yellow',
          width: '50px',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Ignore the scrollbars below.`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          overflow: 'scroll',
          width: '80px',
          height: '80px',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              position: 'absolute',
              top: '50px',
              left: '50px',
              background: 'green',
              color: 'white',
              width: '50px',
              height: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(p);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('004-ref', async () => {
    let positioned;
    positioned = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'positioned',
        style: {
          background: 'green',
          color: 'white',
          left: '0',
          position: 'absolute',
          top: '0',
          width: '100px',
        },
      },
      [createText(`PASS`)]
    );
    BODY.appendChild(positioned);

    await snapshot();
  });
  it('004', async () => {
    let control;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          color: 'yellow',
          background: 'red',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          width: '80px',
          height: '80px',
          overflow: 'hidden',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              color: 'white',
              background: 'green',
              position: 'absolute',
              top: '0',
              left: '0',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('005-ref', async () => {
    let positioned;
    positioned = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'positioned',
        style: {
          background: 'green',
          color: 'white',
          position: 'absolute',
          right: '0',
          top: '0',
          width: '100px',
        },
      },
      [createText(`PASS`)]
    );
    BODY.appendChild(positioned);

    await snapshot();
  });
  xit('005', async () => {
    let control;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          color: 'yellow',
          background: 'red',
          width: '100px',
          margin: '0 0 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          width: '80px',
          height: '80px',
          overflow: 'hidden',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              color: 'white',
              background: 'green',
              position: 'absolute',
              top: '0',
              right: '0',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('006-ref', async () => {
    let positioned;
    positioned = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'positioned',
        style: {
          background: 'green',
          color: 'white',
          height: '50px',
          left: '50px',
          position: 'absolute',
          top: '50px',
          width: '50px',
        },
      },
      [createText(`PASS`)]
    );
    BODY.appendChild(positioned);

    await snapshot();
  });
  it('006', async () => {
    let control;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          margin: '50px 0 0 50px',
          background: 'red',
          color: 'yellow',
          width: '50px',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          overflow: 'hidden',
          width: '80px',
          height: '80px',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              position: 'absolute',
              top: '50px',
              left: '50px',
              background: 'green',
              color: 'white',
              width: '50px',
              height: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('007', async () => {
    let control;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          color: 'yellow',
          background: 'red',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          width: '80px',
          height: '80px',
          overflow: 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              color: 'white',
              background: 'green',
              position: 'absolute',
              top: '0',
              left: '0',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(overflow);

    await snapshot();
  });
  xit('008', async () => {
    let control;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          color: 'yellow',
          background: 'red',
          width: '100px',
          margin: '0 0 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          width: '80px',
          height: '80px',
          overflow: 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              color: 'white',
              background: 'green',
              position: 'absolute',
              top: '0',
              right: '0',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('009', async () => {
    let control;
    let positioned;
    let overflow;
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          margin: '50px 0 0 50px',
          background: 'red',
          color: 'yellow',
          width: '50px',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`FAIL`)]
    );
    overflow = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'overflow',
        style: {
          overflow: 'auto',
          width: '80px',
          height: '80px',
          'box-sizing': 'border-box',
        },
      },
      [
        (positioned = createElement(
          'div',
          {
            class: 'positioned',
            style: {
              position: 'absolute',
              top: '50px',
              left: '50px',
              background: 'green',
              color: 'white',
              width: '50px',
              height: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        )),
      ]
    );
    BODY.appendChild(control);
    BODY.appendChild(overflow);

    await snapshot();
  });
  it('010-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`There should be green text below.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'green',
        },
      },
      [createText(`This text should be green.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('010', async () => {
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
      [createText(`There should be green text below.`)]
    );
    outer = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'outer',
        style: {
          overflow: 'auto',
          color: 'green',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
   This text should be green.
   `),
        (inner = createElement('div', {
          id: 'inner',
          style: {
            position: 'absolute',
            'z-index': '-1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outer);

    await snapshot();
  });
  it('011-ref', async () => {
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
          color: 'green',
        },
      },
      [createText(`This text should be green.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('011', async () => {
    let p;
    let inner;
    let content;
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
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement(
          'div',
          {
            id: 'inner',
            style: {
              position: 'absolute',
              top: '0',
              background: 'white',
              color: 'green',
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(` This text should be green. `)]
        )),
        (content = createElement(
          'div',
          {
            id: 'content',
            style: {
              overflow: 'auto',
              background: 'red',
              color: 'yellow',
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(` FAIL `)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outer);

    await snapshot();
  });
  it('012', async () => {
    let p;
    let positioned;
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
          position: 'relative',
          height: '10px',
          width: '200px',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (inner = createElement(
          'div',
          {
            id: 'inner',
            style: {
              overflow: 'auto',
              'box-sizing': 'border-box',
            },
          },
          [
            (positioned = createElement(
              'div',
              {
                id: 'positioned',
                style: {
                  position: 'absolute',
                  top: '0',
                  width: '200px',
                  background: 'white',
                  color: 'green',
                  'box-sizing': 'border-box',
                },
              },
              [createText(` This text should be green. `)]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(outer);

    await snapshot();
  });
});
