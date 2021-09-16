/*auto generated*/
describe('right-applies', () => {
  it('to-001-ref', async () => {
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
          `Test passes if there is a green square on the right side of the page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'text-align': 'right',
        },
      },
      [
        createElement('img', {
          src: 'assets/1x1-green.png',
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
  it('to-008', async () => {
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
          `Test passes if there is a green stripe on the right side of the page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'green',
          right: '0',
          display: 'inline',
          position: 'absolute',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  it('to-009', async () => {
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
          `Test passes if there is a green square on the right side of the page.`
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
        createElement('span', {
          style: {
            background: 'green',
            right: '0',
            display: 'block',
            height: '96px',
            position: 'absolute',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('to-012', async () => {
    let p;
    let blockDescendant;
    let blockDescendant_1;
    let inlineBlock;
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
          `Test passes if there is a green square on the right side of the page.`
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
        (inlineBlock = createElement(
          'span',
          {
            id: 'inline-block',
            style: {
              right: '0',
              display: 'inline-block',
              position: 'absolute',
              'box-sizing': 'border-box',
            },
          },
          [
            (blockDescendant = createElement('span', {
              class: 'block-descendant',
              style: {
                background: 'green',
                display: 'block',
                height: '48px',
                width: '96px',
                'box-sizing': 'border-box',
              },
            })),
            (blockDescendant_1 = createElement('span', {
              class: 'block-descendant',
              style: {
                background: 'green',
                display: 'block',
                height: '48px',
                width: '96px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
