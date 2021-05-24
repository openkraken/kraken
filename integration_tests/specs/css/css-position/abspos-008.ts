/*auto generated*/
describe('abspos-008', () => {
  xit('ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is `),
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'green',
          'border-top': 'white solid 10px',
          color: 'white',
          float: 'left',
          'font-size': '100px',
        },
      },
      [createText(`X X0`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
