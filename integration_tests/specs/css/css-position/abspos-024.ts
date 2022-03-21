/*auto generated*/
describe('abspos-024', () => {
  it('ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'text-align': 'right',
        },
      },
      [
        createText(`.Test passes if there is a green stripe on the right and `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`no red`)]
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'text-align': 'right',
        },
      },
      [
        createElement('img', {
          src: 'assets/1x1-green.png',
          width: '64',
          height: '16',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
});
