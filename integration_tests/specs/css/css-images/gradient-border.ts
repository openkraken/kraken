/*auto generated*/
describe('gradient-border', () => {
  it('box-ref', async () => {
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

    await snapshot();
  });

  // @TODO: repeating-linear-gradient with percentage impl differs from browser.
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

    await snapshot();
  });
});
