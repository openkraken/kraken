/*auto generated*/
describe('anonymous-box', () => {
  it('generation-001-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if "Filler Text" is centered above the blue stripe.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'text-align': 'center',
          width: '200px',
        },
      },
      [createText(`Filler Text`)]
    );
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'text-align': 'center',
        width: '200px',
        'background-color': 'blue',
        height: '10px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('generation-001', async () => {
    let child;
    let div1;
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          width: '200px',
          'text-align': 'center',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
            Filler Text
            `),
        (child = createElement('div', {
          id: 'child',
          style: {
            width: '200px',
            background: 'blue',
            height: '10px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(div1);

    await snapshot();
  });
});
