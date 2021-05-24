/*auto generated*/
describe('border-applies', () => {
  xit('to-008', async () => {
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
      [createText(`Test passes if there is a hollow green rectangle.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: '10px solid green',
        display: 'inline',
        'font-size': '20px',
        'box-sizing': 'border-box',
      },
    });
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
      [createText(`Test passes if there is a hollow green square.`)]
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
            border: '4px solid green',
            display: 'block',
            height: '96px',
            width: '96px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
  xit('to-012', async () => {
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
      [createText(`Test passes if there is a hollow green square.`)]
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
              border: '4px solid  green',
              display: 'inline-block',
              width: '96px',
              'box-sizing': 'border-box',
            },
          },
          [
            (blockDescendant = createElement(
              'span',
              {
                class: 'block-descendant',
                style: {
                  color: 'white',
                  display: 'block',
                  height: '48px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`a`)]
            )),
            (blockDescendant_1 = createElement(
              'span',
              {
                class: 'block-descendant',
                style: {
                  color: 'white',
                  display: 'block',
                  height: '48px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`b`)]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
});
