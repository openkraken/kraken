/*auto generated*/
describe('left-applies', () => {
  it('to-001-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          margin: '10px 8px',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square on the left side of the page.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'green',
        height: '96px',
        width: '96px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

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
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a green square on the left side of the page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'green',
          font: '96px',
          left: '0',
          display: 'inline',
          position: 'absolute',
          'box-sizing': 'border-box',
        },
      },
      [createText(`X`)]
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
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square on the left side of the page.`
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
            left: '0',
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
          `Test passes if there is a filled green square on the left side of the page.`
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
              left: '0',
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
