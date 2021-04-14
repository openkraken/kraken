/*auto generated*/
describe('abspos-002', () => {
  xit('ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is a hollow blue rectangle.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: 'blue solid 16px',
        height: '32px',
        width: '64px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
