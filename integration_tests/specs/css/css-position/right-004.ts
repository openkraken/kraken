/*auto generated*/
describe('right-004', () => {
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
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`no space between`)]
        ),
        createText(` the blue and orange lines.`),
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
          src: 'assets/blue15x15.png',
          width: '5',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {},
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          width: '5',
          height: '96',
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
