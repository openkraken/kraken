/*auto generated*/
describe('left-004', () => {
  it('ref', async () => {
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
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no space between`)]
        ),
        createText(` the orange and blue lines.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          src: 'assets/swatch-orange.png',
          width: '5',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/blue15x15.png',
          width: '5',
          height: '96',
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot(0.1);
  });
});
