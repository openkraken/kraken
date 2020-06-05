/*auto generated*/
describe('block-replaced', () => {
  it('height-001-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `Test passes if there is no white space between the blue square and the orange lines.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'border-bottom': '2px solid orange',
          'border-top': '2px solid orange',
          'line-height': '15px',
          width: '96px',
        },
      },
      [
        createElement('img', {
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            'vertical-align': 'top',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await matchScreenshot();
  });
  it('height-001', async () => {
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
        createText(
          `Test passes if there is no white space between the blue square and the orange lines.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'border-bottom': '2px solid orange',
          'border-top': '2px solid orange',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          alt: 'blue 15x15',
          src: 'assets/blue15x15.png',
          style: {
            display: 'block',
            'margin-top': 'auto',
            'margin-bottom': 'auto',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await matchScreenshot();
  });
  it('height-002-ref', async () => {
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
        createText(`Test passes if the blue and orange squares have the `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`same height`)]
        ),
        createText(`.`),
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
          src: 'assets/blue15x15.png',
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/swatch-orange.png',
          alt: 'Image download support must be enabled',
          style: {
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await matchScreenshot();
  });
});
