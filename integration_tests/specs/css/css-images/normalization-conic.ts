/*auto generated*/
describe('normalization-conic', () => {
  it('2', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'conic-gradient(blue 150%, red 150%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });

  // @TODO: repeating-conic-gradient with percentage impl differs from browser.
  xit('degenerate', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'repeating-conic-gradient(orange 50%, blue 50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
