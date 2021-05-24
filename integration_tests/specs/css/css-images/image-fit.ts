/*auto generated*/
describe('image-fit', () => {
  it('001', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(
          `A green block appears below. There must be no red on the page.`
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createElement('img', {
          src: 'assets/swatch-green.png',
          alt: 'Failed: image missing',
          style: {
            background: 'red',
            height: '100px',
            width: '50px',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.5);
  });
  it('006', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {},
      },
      [
        createText(
          `The image below should fill the blue border with no red between the border and the image.`
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('img', {
          src: 'assets/intrinsic-size.png',
          alt: 'Failed: image missing',
          style: {
            border: '5px solid blue',
            height: '50px',
            width: '100px',
            'object-fit': 'fill',
            background: 'red',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.5);
  });
});
