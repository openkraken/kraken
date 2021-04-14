/*auto generated*/
describe('blocks-013', () => {
  it('ref', async () => {
    let p;
    let control;
    let control_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if 2 short vertical bars are at the `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`same horizontal position`)]
        ),
        createText(`.`),
      ]
    );
    control = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          'font-size': 'xx-large',
          'padding-left': '20px',
        },
      },
      [createText(`|`)]
    );
    control_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'control',
        style: {
          'font-size': 'xx-large',
          'padding-left': '20px',
        },
      },
      [createText(`|`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(control);
    BODY.appendChild(control_1);

    await snapshot();
  });
});
