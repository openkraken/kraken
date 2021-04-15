/*auto generated*/
describe('position-applies', () => {
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
          `Test passes if there is a green stripe at the bottom of the page.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'green',
          bottom: '0',
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
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square at the bottom of the page.`
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
            bottom: '0',
            display: 'block',
            height: '100px',
            position: 'absolute',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('to-010', async () => {
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
          `Test passes if there is a filled green square at the bottom of the page and a marker bullet on its left-hand side.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'green',
        bottom: '0',
        display: 'NaNpx',
        height: '96px',
        position: 'absolute',
        width: '96px',
        'box-sizing': 'border-box',
      },
    });
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
          `Test passes if there is a filled green square at the bottom of the page.`
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
              background: 'green',
              bottom: '0',
              display: 'inline-block',
              position: 'absolute',
              'box-sizing': 'border-box',
            },
          },
          [
            (blockDescendant = createElement('span', {
              class: 'block-descendant',
              style: {
                display: 'block',
                height: '50px',
                width: '100px',
                'box-sizing': 'border-box',
              },
            })),
            (blockDescendant_1 = createElement('span', {
              class: 'block-descendant',
              style: {
                display: 'block',
                height: '50px',
                width: '100px',
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
