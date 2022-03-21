/*auto generated*/
describe('position-static', () => {
  xit('001-ref', async () => {
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
          `Test passes if an orange stripe is above a blue rectangle and if both have the same width.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'orange',
          height: '192px',
          'line-height': '1.25',
          width: '192px',
        },
      },
      [
        createText(`Filler Text`),
        createElement('br', {
          style: {},
        }),
        createElement('img', {
          src: '/assets/swatch-blue.png',
          width: '192',
          height: '172',
          alt: 'Image download support must be enabled',
          style: {},
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('001', async () => {
    let p;
    let div1;
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
          `Test passes if an orange stripe is above a blue rectangle and if both have the same width.`
        ),
      ]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          background: 'blue',
          height: '192px',
          'line-height': '1.25',
          position: 'relative',
          width: '192px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'orange',
              bottom: '0',
              left: '100px',
              position: 'static',
              right: '0',
              top: '100px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Filler Text`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
});
