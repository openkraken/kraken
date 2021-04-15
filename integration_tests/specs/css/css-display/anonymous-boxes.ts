/*auto generated*/
describe('anonymous-boxes', () => {
  it('inheritance-001-ref', async () => {
    let p;
    let blue;
    let orange;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if the 2 squares have the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`same size`)]
        ),
        createText(`.`),
      ]
    );
    blue = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'blue',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'blue',
      },
    });
    orange = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'orange',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'orange',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(blue);
    BODY.appendChild(orange);

    await snapshot();
  });
  it('inheritance-001', async () => {
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
        createText(`Test passes if the 2 squares have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same size`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'blue',
          'font-size': '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
            X
            `),
        createElement(
          'div',
          {
            style: {
              color: 'orange',
              'font-size': '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`X`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
