/*auto generated*/
describe('normalization-radial', () => {
  it('2', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'radial-gradient(blue 150%, red 150%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });

  // @TODO: repeating-radial-gradient with percentage impl differs from browser.
  xit('degenerate', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'repeating-radial-gradient(orange 50%, blue 50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
