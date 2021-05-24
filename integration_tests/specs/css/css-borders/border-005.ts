/*auto generated*/
describe('border-005', () => {
  it('ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a filled blue square and `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'blue',
        height: '192px',
        width: '192px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
});
