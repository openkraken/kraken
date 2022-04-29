/*auto generated*/
describe('right', () => {
  it('004', async () => {
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
        createText(` the blue and orange lines.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '5px solid orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '5px solid blue',
            right: '-0px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('005', async () => {
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
        createText(` the blue and orange lines.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '5px solid orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '5px solid blue',
            right: '0px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('006', async () => {
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
        createText(` the blue and orange lines.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '5px solid orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '5px solid blue',
            right: '+0px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });

  // @TODO: Support CSS inherit keyword.
  xit('007', async () => {
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
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '3px solid red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '3px solid black',
            'margin-right': '-99px',
            right: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });

  // @TODO: Support CSS inherit keyword.
  xit('008', async () => {
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
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '3px solid red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '3px solid black',
            'margin-right': '-99px',
            right: '+96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('016', async () => {
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
        createText(` the blue and orange lines.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '5px solid orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '5px solid blue',
            right: '-0pt',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

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
        createText(` the blue and orange lines.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '5px solid orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '5px solid blue',
            right: '0pt',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('018', async () => {
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
        createText(` the blue and orange lines.`),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '5px solid orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '5px solid blue',
            right: '+0pt',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });

  // @TODO: Support CSS inherit keyword.
  xit('019', async () => {
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
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '72pt solid red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '72pt solid black',
            'margin-right': '-144pt',
            right: '72pt',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });

  // @TODO: Support CSS inherit keyword.
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
          direction: 'rtl',
          height: '96px',
          position: 'relative',
          'border-right': '72pt solid red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            direction: 'rtl',
            height: '96px',
            position: 'relative',
            'border-right': '72pt solid black',
            'margin-right': '-144pt',
            right: '+72pt',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
});
