/*auto generated*/
describe('position-006', () => {
  it('ref', async () => {
    let p;
    let p_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be 2 sentences on this page.`)]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The test has passed if you see this as the 2nd sentence.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);

    await snapshot();

    await snapshot();
  });
});
