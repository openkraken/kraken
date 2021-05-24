/*auto generated*/
describe('normalization-linear', () => {
  it('2', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'linear-gradient(blue 150%, red 150%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
  xit('degenerate', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'repeating-linear-gradient(orange 50%, blue 50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
