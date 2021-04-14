/*auto generated*/
describe('normalization', () => {
  it('conic', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'conic-gradient(green -50%, blue -50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
  it('linear', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'linear-gradient(green -50%, blue -50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
  it('radial', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '100px',
        height: '100px',
        'background-image': 'linear-gradient(green -50%, blue -50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
