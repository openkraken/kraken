/*auto generated*/
describe('image-min', () => {
  it('max-content-intrinsic-size-change-001-ref', async () => {
    let img;
    img = createElement('img', {
      src: 'assets/60x60-green.png',
      style: {
        border: '1px solid black',
        height: '30px',
        width: '60px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(img);

    await snapshot(0.1);
  });
});
