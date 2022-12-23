/*auto generated*/
describe('gradient-move', () => {
  it('stops-ref', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '400px',
        height: '300px',
        'background-image':
          'linear-gradient(to right, yellow 0%, blue 70%, green 70%, green 100%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
  it('stops', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '400px',
        height: '300px',
        'background-image':
          'linear-gradient(to right, yellow, blue 70%, green 0)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
