/*auto generated*/
describe('positioning-float', () => {
  it('001-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is the word "P A S S".`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'font-size': '30px',
        },
      },
      [createText(`P A S S`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
