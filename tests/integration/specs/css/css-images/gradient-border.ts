/*auto generated*/
describe('gradient-border', () => {
  xit('box-ref', async () => {
    let x;
    x = createElement('div', {
      id: 'x',
      style: {
        width: '280px',
        height: '280px',
        'background-image':
          'linear-gradient(to bottom right, white, black, white)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(x);

    await matchScreenshot();
  });
  xit('box', async () => {
    let x;
    x = createElement('div', {
      id: 'x',
      style: {
        'background-origin': 'border-box',
        width: '200px',
        height: '200px',
        'border-style': 'solid',
        'border-width': '40px',
        'border-color': 'transparent',
        'background-image':
          'repeating-linear-gradient(to bottom right, white, black, white)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(x);

    await matchScreenshot();
  });
});
