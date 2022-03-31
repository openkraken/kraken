/*auto generated*/
describe('tiled', () => {
  // @TODO: linear-gradient with percentage impl differs from browser.
  xit('gradients', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '400px',
        height: '200px',
        'background-size': '25% 50%',
        'background-image':
          'linear-gradient(to bottom left, red 50%, transparent 50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
