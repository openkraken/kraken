/*auto generated*/
describe('linear-gradient', () => {
  it('1', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '400px',
        height: '300px',
        'background-image': 'linear-gradient(to right, black 0%, red, gold)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await matchViewportSnapshot();
  });
  it('2', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '400px',
        height: '300px',
        'background-image': 'linear-gradient(to right, black, red, gold)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await matchViewportSnapshot();
  });
  it('ref', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '400px',
        height: '300px',
        'background-image':
          'linear-gradient(to right, black 0%, red 50%, gold 100%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await matchViewportSnapshot();
  });
});
