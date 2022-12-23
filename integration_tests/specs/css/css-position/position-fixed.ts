/*auto generated*/
describe('position-fixed', () => {
  it('001', async () => {
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
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            height: '100px',
            width: '100px',
            background: 'green',
            position: 'fixed',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            height: '100px',
            width: '100px',
            background: 'red',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let div1;
    let filler;
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
          `Test passes if the blue stripe does not move when the page is scrolled.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text`)]
    );
    filler = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'filler',
      style: {
        height: '6000px',
        margin: '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div1);
    BODY.appendChild(filler);

    await snapshot();
  });
  it('005', async () => {
    let prerequisite;
    let p;
    let spacer;
    let fixed;
    prerequisite = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'prerequisite',
        style: {
          margin: '0',
          padding: '10px 0 0 10px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`PREREQUISITE: Switch to print preview or a paged view.`)]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          margin: '0',
          padding: '10px 0 0 10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is only one page and there is no red underlined text visible when paginated or printed.`
        ),
      ]
    );
    fixed = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'fixed',
        style: {
          height: '100%',
          position: 'fixed',
          top: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (spacer = createElement('div', {
          id: 'spacer',
          style: {
            height: '100%',
            'box-sizing': 'border-box',
          },
        })),
        createElement(
          'span',
          {
            style: {
              color: 'red',
              'text-decoration': 'underline',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              `Test fails if this line of text is visible when the page is paginated or printed.`
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(prerequisite);
    BODY.appendChild(p);
    BODY.appendChild(fixed);

    await snapshot();
  });
  it('007-ref', async () => {
    let div;
    let p;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createElement('img', {
          src: 'assets/black15x15.png',
          width: '96',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-left': '8px',
          'margin-top': '0px',
        },
      },
      [
        createText(
          `Test passes if there is a black square in the upper-left corner of the page.`
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(p);

    await snapshot(0.5);
  });
  it('007', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-top': '96px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a black square in the upper-left corner of the page.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'black',
        float: 'right',
        height: '96px',
        position: 'fixed',
        top: '0',
        left: '0',
        width: '96px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
