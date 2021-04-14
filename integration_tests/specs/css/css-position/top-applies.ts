/*auto generated*/
describe('top-applies', () => {
  it('to-001-ref', async () => {
    let div;
    let p;
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'green',
        height: '96px',
        width: '96px',
      },
    });
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-top': '48px',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square at the top of the page.`
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(p);

    await snapshot();
  });
  it('to-008', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-top': '144px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a green stripe at the top of the page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'green',
          top: '0',
          display: 'inline',
          position: 'absolute',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('to-009', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'margin-top': '144px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square at the top of the page.`
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
            top: '0',
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
          'margin-top': '144px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square at the top of the page.`
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
              top: '0',
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
